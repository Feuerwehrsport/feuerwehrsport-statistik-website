# frozen_string_literal: true

class Series::Round < ApplicationRecord
  include Caching::Keys
  include Series::Participationable

  belongs_to :kind, class_name: 'Series::Kind'
  has_many :cups, class_name: 'Series::Cup', dependent: :destroy
  has_many :team_assessments, class_name: 'Series::TeamAssessment', dependent: :destroy
  has_many :team_participations, through: :team_assessments, class_name: 'Series::TeamParticipation'
  has_many :person_assessments, class_name: 'Series::PersonAssessment', dependent: :destroy
  has_many :person_participations, through: :person_assessments, class_name: 'Series::PersonParticipation',
                                   source: :person_participations

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

  %i[team person].each do |entity_key|
    jsonb_as_text :"#{entity_key}_assessments_config_jsonb"
    validate do
      send("#{entity_key}_assessments_configs").each_with_index do |config, index|
        next if config.valid?

        config.errors.each do |error|
          errors.add(:"#{entity_key}_assessments_config_jsonb_text", "Eintrag #{index}: #{error.full_message}")
          errors.add(:"#{entity_key}_assessments_config_jsonb", "Eintrag #{index}: #{error.full_message}")
        end
      end
    end

    define_method("#{entity_key}_assessments_configs") do
      unless send("#{entity_key}_assessments_config_jsonb").is_a?(Array)
        errors.add(:"#{entity_key}_assessments_config_jsonb", :invalid)
        errors.add(:"#{entity_key}_assessments_config_jsonb_text", :invalid)
        return []
      end
      send("#{entity_key}_assessments_config_jsonb").map do |h|
        unless h.is_a?(Hash)
          errors.add(:"#{entity_key}_assessments_config_jsonb", :invalid)
          errors.add(:"#{entity_key}_assessments_config_jsonb_text", :invalid)
          return []
        end
        Series::AssessmentConfig.new(h).tap do |config|
          config.round = self
          config.entity_key = entity_key
        end
      end
    end
  end

  def disciplines
    (team_assessments.distinct.pluck(:discipline) + person_assessments.distinct.pluck(:discipline)).uniq.sort
  end

  def team_assessment_rows(gender, cache: true)
    @team_assessment_rows ||= calculate_rows(cache)
    @team_assessment_rows[gender]
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
      team_assessments_configs.each do |config|
        rows[config.key] = teams(config.key).values.sort
        rows[config.key].each { |row| row.calculate_rank!(rows[config.key]) }
        aggregate_class.special_sort!(rows[config.key])
      end
      rows
    end
  end
end
