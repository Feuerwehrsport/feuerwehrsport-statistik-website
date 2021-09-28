# frozen_string_literal: true

class CreateM3Websites < ActiveRecord::Migration[4.2]
  def change
    create_table :m3_websites do |t|
      t.string :name, null: false
      t.string :domain, null: false
      t.string :title, null: false

      t.timestamps null: false
    end
  end
end
