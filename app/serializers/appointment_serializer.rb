class AppointmentSerializer < ActiveModel::Serializer
  attributes :id, :name, :place_id, :event_id, :place, :event, :disciplines, :dated_at, :description, :updateable

  def place
    object.place.to_s
  end

  def event
    object.event.to_s
  end

  def dated_at
    object.dated_at_iso
  end
end
