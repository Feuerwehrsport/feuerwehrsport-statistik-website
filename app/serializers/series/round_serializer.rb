# frozen_string_literal: true

class Series::RoundSerializer < ActiveModel::Serializer
  attributes :id, :name, :year, :full_cup_count, :official, :team_assessments_configs, :person_assessments_configs

  def name
    object.kind&.name
  end

  def team_assessments_configs
    object.team_assessments_config_jsonb
  end

  def person_assessments_configs
    object.person_assessments_config_jsonb
  end
end
