# frozen_string_literal: true

class Series::Round < ApplicationRecord
  include Caching::Keys
  include Series::Participationable

  jsonb_as_text :team_assessments_config_jsonb
  jsonb_as_text :person_assessments_config_jsonb

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
  validate :validate_assessment_configs

  def team_assessments_configs
    unless team_assessments_config_jsonb.is_a?(Array)
      errors.add(:team_assessments_config_jsonb, :invalid)
      errors.add(:team_assessments_config_jsonb_text, :invalid)
      return []
    end
    team_assessments_config_jsonb.map do |h|
      unless h.is_a?(Hash)
        errors.add(:team_assessments_config_jsonb, :invalid)
        errors.add(:team_assessments_config_jsonb_text, :invalid)
        return []
      end
      Series::AssessmentConfig.new(h)
    end
  end

  def person_assessments_configs
    unless person_assessments_config_jsonb.is_a?(Array)
      errors.add(:person_assessments_config_jsonb, :invalid)
      errors.add(:person_assessments_config_jsonb_text, :invalid)
      return []
    end
    person_assessments_config_jsonb.map do |h|
      unless h.is_a?(Hash)
        errors.add(:person_assessments_config_jsonb, :invalid)
        errors.add(:person_assessments_config_jsonb_text, :invalid)
        return []
      end
      Series::AssessmentConfig.new(h)
    end
  end

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

  private

  def validate_assessment_configs
    team_assessments_configs.each_with_index do |config, index|
      next if config.valid?

      config.errors.each do |error|
        errors.add(:team_assessments_config_jsonb_text, "Eintrag #{index}: #{error.full_message}")
        errors.add(:team_assessments_config_jsonb, "Eintrag #{index}: #{error.full_message}")
      end
    end
    person_assessments_configs.each_with_index do |config, index|
      next if config.valid?

      config.errors.each do |error|
        errors.add(:person_assessments_config_jsonb_text, "Eintrag #{index}: #{error.full_message}")
        errors.add(:person_assessments_config_jsonb, "Eintrag #{index}: #{error.full_message}")
      end
    end
  end
end
