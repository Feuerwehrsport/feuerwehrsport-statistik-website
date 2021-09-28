# frozen_string_literal: true

class AddConditionTypeToM3PageComponents < ActiveRecord::Migration[4.2]
  def change
    add_column :m3_page_components, :condition_type, :string
  end
end
