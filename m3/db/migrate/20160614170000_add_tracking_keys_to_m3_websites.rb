# frozen_string_literal: true

class AddTrackingKeysToM3Websites < ActiveRecord::Migration[4.2]
  def change
    add_column :m3_websites, :facebook_pixel_id, :string, limit: 200
    add_column :m3_websites, :google_analytics_key, :string, limit: 200
  end
end
