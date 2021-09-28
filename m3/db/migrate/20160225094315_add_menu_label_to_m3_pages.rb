# frozen_string_literal: true

class AddMenuLabelToM3Pages < ActiveRecord::Migration[4.2]
  def change
    add_column :m3_pages, :menu_label, :string
  end
end
