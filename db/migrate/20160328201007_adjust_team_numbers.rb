class AdjustTeamNumbers < ActiveRecord::Migration
  def change
    execute "UPDATE scores SET team_number = team_number + 1;"
    execute "UPDATE group_scores SET team_number = team_number + 1;"
  end
end
