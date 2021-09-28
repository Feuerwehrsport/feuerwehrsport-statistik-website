# frozen_string_literal: true

class CreateM3PageComponents < ActiveRecord::Migration[4.2]
  def change
    remove_column :m3_pages, :content_type, :string
    remove_column :m3_pages, :content_id, :integer

    create_table :m3_page_components do |t|
      t.references :page, null: false, index: true
      t.references :parent, null: true, index: true
      t.references :resource, null: true, polymorphic: true, index: true
      t.boolean :published, default: true, null: false
      t.integer :layout, null: false, default: 100
      t.integer :style, null: false, default: 1

      t.timestamps null: false
    end
    add_foreign_key :m3_page_components, :m3_pages, column: :page_id
    add_foreign_key :m3_page_components, :m3_page_components, column: :parent_id
  end
end
