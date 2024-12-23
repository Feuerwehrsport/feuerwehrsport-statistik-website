# frozen_string_literal: true

class Series::Round < ApplicationRecord
  include Caching::Keys
  include Series::Participationable

  belongs_to :kind, class_name: 'Series::Kind'
  has_many :cups, class_name: 'Series::Cup', dependent: :destroy
  has_many :assessments, class_name: 'Series::Assessment', dependent: :destroy
  has_many :participations, through: :assessments, class_name: 'Series::Participation'

  default_scope -> { order(year: :desc) }
  scope :cup_count, -> do
    select("#{table_name}.*, COUNT(#{Series::Cup.table_name}.id) AS cup_count")
      .joins(:cups)
      .group("#{table_name}.id")
  end
  scope :with_team, ->(team_id, gender) do
    joins(:participations).where(series_participations: { team_id: })
                          .merge(Series::TeamAssessment.gender(gender)).distinct
  end

  delegate :name, :slug, to: :kind

  schema_validations

  def disciplines
    assessments.pluck(:discipline).uniq.sort
  end

  def team_assessment_rows(gender, cache: true)
    @team_assessment_rows ||= calculate_rows(cache)
    @team_assessment_rows[gender]
  end

  def aggregate_class
    @aggregate_class ||= Firesport::Series::Handler.team_class_for(aggregate_type)
  end

  TeamRound = Struct.new(:round, :cups, :row, :team_number)

  def self.for_team(team_id, gender)
    round_structs = {}
    Series::Round.with_team(team_id, gender).decorate.each do |round|
      round_structs[round.name] ||= []
      round.team_assessment_rows(gender).select { |r| r.team.id == team_id }.each do |row|
        next if row.rank.nil?

        round_structs[round.name].push(TeamRound.new(
                                         round,
                                         round.cups,
                                         row.decorate,
                                         row.team_number,
                                       ))
      end
      round_structs.delete(round.name) if round_structs[round.name].empty?
    end
    round_structs
  end

  def cups_left
    full_cup_count - cup_count
  end

  def cup_count
    attributes['cup_count'] || cups.count
  end

  def complete?
    cups_left&.zero? || false
  end

  protected

  def calculate_rows(cache)
    Caching::Cache.fetch(caching_key(:calculate_rows), force: !cache) do
      rows = {}
      Genderable::GENDER_KEYS.each do |gender|
        rows[gender] = teams(gender).values.sort
        rows[gender].each { |row| row.calculate_rank!(rows[gender]) }
        aggregate_class.special_sort!(rows[gender])
      end
      rows
    end
  end

  def teams(gender)
    teams = {}
    Series::TeamParticipation.where(assessment: assessments.gender(gender)).each do |participation|
      teams[participation.entity_id] ||= aggregate_class.new(self, participation.team, participation.team_number)
      teams[participation.entity_id].add_participation(participation)
    end
    teams
  end
end
