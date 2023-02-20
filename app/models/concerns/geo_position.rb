# frozen_string_literal: true

module GeoPosition
  extend ActiveSupport::Concern
  included do
    scope :positioned, -> { where.not(latitude: nil, longitude: nil) }
  end

  def positioned?
    latitude.present? && longitude.present?
  end

  def latlon
    [latitude.to_f, longitude.to_f]
  end
end
