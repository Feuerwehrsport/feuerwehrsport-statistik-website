# frozen_string_literal: true

class Registrations::CompetitionSerializer < ActiveModel::Serializer
  attributes :name, :place, :date, :description, :teams, :assessments, :people, :person_tag_list, :team_tag_list

  def teams
    object.teams.map(&:to_serializer)
  end

  def people
    object.people.map(&:to_serializer)
  end

  def assessments
    object.assessments.map(&:to_serializer)
  end
end
