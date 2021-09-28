# frozen_string_literal: true

class AddPositionToM3PageComponents < ActiveRecord::Migration[4.2]
  def change
    add_column :m3_page_components, :position, :integer, null: false, default: 0
  end
end
