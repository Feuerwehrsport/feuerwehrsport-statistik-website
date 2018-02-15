class AddCountsToTeams < ActiveRecord::Migration
  def change
    add_column :teams, :members_count, :integer, null: false, default: 0
    add_column :teams, :competitions_count, :integer, null: false, default: 0
  end
end
