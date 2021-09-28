# frozen_string_literal: true

class CreateM3Assets < ActiveRecord::Migration[4.2]
  def change
    create_table :m3_assets do |t|
      t.references :website, index: true, null: false
      t.string :file
      t.string :name, limit: 200
      t.boolean :image, default: false, null: false

      t.timestamps null: false
    end
    add_foreign_key :m3_assets, :m3_websites, column: :website_id
  end
end
