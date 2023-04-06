# frozen_string_literal: true

class Registrations::TeamSerializer < ActiveModel::Serializer
  attributes :id, :name, :shortcut, :team_number, :statitics_team_id, :assessments, :tag_names

  def statitics_team_id
    object.team_id
  end

  def assessments
    object.assessments.map(&:id)
  end
end
