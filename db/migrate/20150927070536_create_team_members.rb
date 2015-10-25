class CreateTeamMembers < ActiveRecord::Migration
  def up
    sql = "CREATE OR REPLACE VIEW team_members AS
      #{GroupScore.joins(:person_participations).select(:team_id, :person_id).to_sql} 
      UNION 
      #{Score.select(:team_id, :person_id).where.not(team_id: nil).to_sql}
    "
    self.connection.execute  sql
  end

  def down
    self.connection.execute "DROP VIEW IF EXISTS team_members"
  end
end