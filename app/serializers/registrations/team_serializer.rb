# frozen_string_literal: true
class Registrations::TeamSerializer < ActiveModel::Serializer
  attributes :id, :name, :shortcut, :team_number, :statitics_team_id, :gender, :assessments, :tag_names,
             :federal_state

  def statitics_team_id
    object.team_id
  end

  def assessments
    object.assessments.map(&:id)
  end

  def federal_state
    object.federal_state.try(:shortcut)
  end
end
