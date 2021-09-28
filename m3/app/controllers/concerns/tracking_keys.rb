# frozen_string_literal: true

module TrackingKeys
  extend ActiveSupport::Concern

  included do
    helper_method :facebook_pixel_id
    helper_method :google_analytics_key
    helper_method :google_tag_manager_key
  end

  class_methods do
    def disable_tracking
      define_method(:tracking?) { false }
    end
  end

  def facebook_pixel_id
    tracking? ? @m3_website.facebook_pixel_id : nil
  end

  def google_analytics_key
    tracking? ? @m3_website.google_analytics_key : nil
  end

  def google_tag_manager_key
    tracking? ? @m3_website.google_tag_manager_key : nil
  end

  def tracking?
    true
  end
end
