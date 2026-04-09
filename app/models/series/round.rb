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
    if gender.in?([:female, 'female'])
      gender = 0
    elsif gender.in?([:male, 'male'])
      gender = 1
    end
    joins(:team_participations).where(series_team_participations: { team_id:, team_gender: gender })
                               .distinct
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
    (team_assessments_configs + person_assessments_configs).map(&:disciplines).flatten.uniq.sort
  end

  def team_config_for(key)
    team_assessments_configs.find { |c| c.key == key }
  end

  def person_config_for(key)
    person_assessments_configs.find { |c| c.key == key }
  end

  TeamRound = Struct.new(:round, :cups, :row, :team_number)

  def self.for_team(team_id, gender)
    if gender.in?([:female, 'female'])
      gender = 0
    elsif gender.in?([:male, 'male'])
      gender = 1
    end
    round_structs = {}
    Series::Round.with_team(team_id, gender).decorate.each do |round|
      round.team_assessments_configs.each do |config|
        config.rows.select { |r| r.team.id == team_id && r.team_gender == gender }.each do |row|
          next if row.rank.nil?

          round_structs[round.name] ||= []
          round_structs[round.name].push(TeamRound.new(
                                           round,
                                           round.cups,
                                           row.decorate,
                                           row.team_number,
                                         ))
        end
      end
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
end
