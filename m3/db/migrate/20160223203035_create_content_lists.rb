# frozen_string_literal: true

class CreateContentLists < ActiveRecord::Migration[4.2]
  def change
    create_table :content_lists do |t|
      t.string :key, null: false
      t.references :replaced_list, index: true
      t.datetime :published_at

      t.timestamps null: false
    end
    add_foreign_key :content_lists, :content_lists, column: :replaced_list_id
  end
end
