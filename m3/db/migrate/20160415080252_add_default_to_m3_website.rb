# frozen_string_literal: true

class AddDefaultToM3Website < ActiveRecord::Migration[4.2]
  def change
    add_column :m3_websites, :default_site, :boolean, null: false, default: false
    add_index :m3_websites, :default_site, unique: true
  end
end
