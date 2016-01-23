module Series
  class ParticipationSerializer < ActiveModel::Serializer
    attributes :id, :points, :rank, :time, :second_time, :assessment_id
  end
end
