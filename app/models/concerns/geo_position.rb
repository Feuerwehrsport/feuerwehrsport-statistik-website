# frozen_string_literal: true

module GeoPosition
  extend ActiveSupport::Concern

  included do
    scope :positioned, -> { where.not(latitude: nil).where.not(longitude: nil) }
  end

  def positioned?
    latitude.present? && longitude.present?
  end

  def latlon
    [latitude.to_f, longitude.to_f]
  end

  EARTH_RADIUS_KM = 6371.0

  # great circle distance (haversine) in km
  def self.distance_km((lat1, lon1), (lat2, lon2))
    rad = Math::PI / 180
    a = (Math.sin((lat2 - lat1) * rad / 2)**2) +
        (Math.cos(lat1 * rad) * Math.cos(lat2 * rad) * (Math.sin((lon2 - lon1) * rad / 2)**2))
    2 * EARTH_RADIUS_KM * Math.asin(Math.sqrt(a))
  end
end
