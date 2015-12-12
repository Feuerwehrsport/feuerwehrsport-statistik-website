class AppointmentSerializer < ActiveModel::Serializer
  attributes :id, :name, :place_id, :event_id, :place, :event, :disciplines, :dated_at, :description

  def place
    object.place.to_s
  end

  def event
    object.event.to_s
  end
end
