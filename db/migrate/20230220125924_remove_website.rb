# frozen_string_literal: true

class RemoveWebsite < ActiveRecord::Migration[5.2]
  def change
    remove_column :m3_delivery_settings, :website_id
    remove_column :m3_logins, :website_id
    remove_column :m3_assets, :website_id
    drop_table :m3_websites
  end
end
