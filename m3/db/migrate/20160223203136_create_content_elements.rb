# frozen_string_literal: true

class CreateContentElements < ActiveRecord::Migration[4.2]
  def change
    create_table :content_elements do |t|
      t.string :type
      t.references :list, index: true
      t.integer :position, null: false, default: 0
      t.text :fields
      t.integer :integration, null: false, default: 0

      t.timestamps null: false
    end
    add_foreign_key :content_elements, :content_lists, column: :list_id
  end
end
