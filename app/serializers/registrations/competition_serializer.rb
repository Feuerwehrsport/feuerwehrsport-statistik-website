# frozen_string_literal: true

class Registrations::CompetitionSerializer < ActiveModel::Serializer
  attributes :name, :place, :date, :description, :bands

  def bands
    object.bands.map(&:to_serializer)
  end
end
