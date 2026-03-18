# frozen_string_literal: true

class Series::PersonParticipationSerializer < ActiveModel::Serializer
  attributes :id, :points, :rank, :time, :second_time, :person_assessment_id, :cup_id, :person_id,
             :points_correction, :points_correction_hint
end
