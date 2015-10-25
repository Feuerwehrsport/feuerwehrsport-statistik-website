class CreateTeamCompetitions < ActiveRecord::Migration
  def up
    sql = "CREATE OR REPLACE VIEW team_competitions AS
      #{GroupScore.joins(:group_score_category).select(:team_id, :competition_id).to_sql} 
      UNION 
      #{Score.select(:team_id, :competition_id).where.not(team_id: nil).to_sql}
    "
    self.connection.execute  sql
  end

  def down
    self.connection.execute "DROP VIEW IF EXISTS team_competitions"
  end
end