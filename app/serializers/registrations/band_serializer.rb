# frozen_string_literal: true

class Registrations::BandSerializer < ActiveModel::Serializer
  attributes :name, :gender, :teams, :assessments, :people, :person_tag_list, :team_tag_list

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
