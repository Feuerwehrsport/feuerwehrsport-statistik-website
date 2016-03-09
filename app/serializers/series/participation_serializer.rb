module Series
  class ParticipationSerializer < ActiveModel::Serializer
    attributes :id, :points, :rank, :time, :second_time, :assessment_id, :cup_id, :type, :team_id, :team_number, :person_id
  end
end
