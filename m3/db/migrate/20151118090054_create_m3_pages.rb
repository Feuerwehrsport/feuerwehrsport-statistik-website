# frozen_string_literal: true

class CreateM3Pages < ActiveRecord::Migration[4.2]
  def change
    create_table :m3_pages do |t|
      t.references :website, index: true, null: false
      t.string :name, null: false
      t.string :slug, index: true, null: false
      t.string :title
      t.string :redirects_to
      t.references :content, polymorphic: true, index: true, null: false

      t.timestamps null: false
    end
    add_foreign_key :m3_pages, :m3_websites, column: :website_id
  end
end
