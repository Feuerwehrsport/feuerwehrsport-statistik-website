# frozen_string_literal: true

class AddConditionToM3Pages < ActiveRecord::Migration[4.2]
  def change
    add_column :m3_pages, :condition_type, :string
  end
end
