# frozen_string_literal: true

class Series::TeamParticipationSerializer < ActiveModel::Serializer
  attributes :id, :points, :rank, :time, :second_time, :team_assessment_id, :cup_id, :team_id, :team_number,
             :team_gender
end
