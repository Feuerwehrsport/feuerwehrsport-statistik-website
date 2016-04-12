class AddCountsToCompetitions < ActiveRecord::Migration
  def change
    add_column :competitions, :hl_female, :integer, null: false, default: 0
    add_column :competitions, :hl_male, :integer, null: false, default: 0
    add_column :competitions, :hb_female, :integer, null: false, default: 0
    add_column :competitions, :hb_male, :integer, null: false, default: 0
    add_column :competitions, :gs, :integer, null: false, default: 0
    add_column :competitions, :fs_female, :integer, null: false, default: 0
    add_column :competitions, :fs_male, :integer, null: false, default: 0
    add_column :competitions, :la_female, :integer, null: false, default: 0
    add_column :competitions, :la_male, :integer, null: false, default: 0
    add_column :competitions, :teams_count, :integer, null: false, default: 0
    add_column :competitions, :people_count, :integer, null: false, default: 0
  end
end
