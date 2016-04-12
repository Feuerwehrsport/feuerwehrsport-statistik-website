class AddCountToPeople < ActiveRecord::Migration
  def change
    add_column :people, :hb_count, :integer, null: false, default: 0
    add_column :people, :hl_count, :integer, null: false, default: 0
    add_column :people, :la_count, :integer, null: false, default: 0
    add_column :people, :fs_count, :integer, null: false, default: 0
    add_column :people, :gs_count, :integer, null: false, default: 0
  end
end
