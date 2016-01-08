class CompetitionSerializer < ActiveModel::Serializer
  attributes :id, :name, :place, :event, :date

  def place
    object.place.to_s
  end

  def event
    object.event.to_s
  end
end
