# frozen_string_literal: true

class AddKeyToM3Websites < ActiveRecord::Migration[4.2]
  def change
    add_column :m3_websites, :key, :string, limit: 200
    M3::Website.all.each { |w| w.update!(key: w.name.parameterize) }
    change_column_null :m3_websites, :key, false
  end
end
