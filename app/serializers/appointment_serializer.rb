# frozen_string_literal: true
class AppointmentSerializer < ActiveModel::Serializer
  attributes :id, :name, :event_id, :place, :event, :disciplines, :dated_at, :description, :updateable

  def event
    object.event.to_s
  end

  def dated_at
    object.dated_at_iso
  end
end
