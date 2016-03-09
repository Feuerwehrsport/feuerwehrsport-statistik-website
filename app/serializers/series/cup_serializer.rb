class Series::CupSerializer < ActiveModel::Serializer
  attributes :id, :competition_id, :round_id, :date, :place

  def place
    object.competition.place.name
  end

  def date
    object.competition.date
  end
end
