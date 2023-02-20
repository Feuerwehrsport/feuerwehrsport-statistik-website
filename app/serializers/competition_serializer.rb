# frozen_string_literal: true
class CompetitionSerializer < ActiveModel::Serializer
  attributes :id, :name, :place, :event, :date, :hint_content

  def place
    object.place.to_s
  end

  def event
    object.event.to_s
  end

  def date
    object.date_iso
  end
end
