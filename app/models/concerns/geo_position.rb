module GeoPosition
  extend ActiveSupport::Concern
  included do
  end

  def positioned?
    latitude.present? && longitude.present?
  end

  def latlon
    [latitude.to_f, longitude.to_f]
  end
end
