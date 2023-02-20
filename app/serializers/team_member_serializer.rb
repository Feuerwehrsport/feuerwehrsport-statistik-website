# frozen_string_literal: true
class TeamMemberSerializer < ActiveModel::Serializer
  attributes :person_id, :team_id
end
