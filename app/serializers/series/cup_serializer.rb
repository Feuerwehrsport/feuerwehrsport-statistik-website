# frozen_string_literal: true
class Series::CupSerializer < ActiveModel::Serializer
  attributes :id, :competition_id, :round_id, :date, :place

  def place
    object.competition.place.name
  end

  def date
    object.competition.date_iso
  end
end
