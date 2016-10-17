class AddOfficialToSeriesRounds < ActiveRecord::Migration
  def change
    add_column :series_rounds, :official, :boolean, default: false, null: false
  end
end
