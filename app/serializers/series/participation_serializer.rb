# frozen_string_literal: true
class Series::ParticipationSerializer < ActiveModel::Serializer
  attributes :id, :points, :rank, :time, :second_time, :assessment_id, :cup_id, :type, :team_id, :team_number,
             :person_id
end
