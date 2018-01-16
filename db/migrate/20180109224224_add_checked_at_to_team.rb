class AddCheckedAtToTeam < ActiveRecord::Migration
  def change
    add_column :teams, :checked_at, :datetime
  end
end
