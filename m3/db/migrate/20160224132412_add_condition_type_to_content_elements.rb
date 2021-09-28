# frozen_string_literal: true

class AddConditionTypeToContentElements < ActiveRecord::Migration[4.2]
  def change
    add_column :content_elements, :condition_type, :string
  end
end
