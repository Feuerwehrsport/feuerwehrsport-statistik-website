# frozen_string_literal: true

# asset management for CKEditor (former m3 engine) is not used anymore, last upload in 2018
class DropAssets < ActiveRecord::Migration[8.1]
  def change
    drop_table :assets, id: :serial do |t|
      t.string :file
      t.string :name, limit: 200
      t.boolean :image, default: false, null: false
      t.datetime :created_at, precision: nil, null: false
      t.datetime :updated_at, precision: nil, null: false
    end
  end
end
