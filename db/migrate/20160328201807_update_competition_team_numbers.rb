class UpdateCompetitionTeamNumbers < ActiveRecord::Migration
  def up
    self.connection.execute "DROP VIEW IF EXISTS competition_team_numbers"

    columns = [:team_id, :team_number, :gender, :competition_id]
    sql = "CREATE OR REPLACE VIEW competition_team_numbers AS
      #{GroupScore.joins(:group_score_category).select(*columns).where("team_number > 0").to_sql} 
      UNION 
      #{Score.select(*columns).joins(:person).where("team_number > 0").where.not(team_id: nil).to_sql}
    "
    self.connection.execute  sql
  end

  def down
  end
end
