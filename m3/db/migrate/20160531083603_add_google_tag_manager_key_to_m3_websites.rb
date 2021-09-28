# frozen_string_literal: true

class AddGoogleTagManagerKeyToM3Websites < ActiveRecord::Migration[4.2]
  def change
    add_column :m3_websites, :google_tag_manager_key, :string, limit: 200
  end
end
