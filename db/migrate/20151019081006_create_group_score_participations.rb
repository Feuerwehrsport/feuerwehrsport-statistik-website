class CreateGroupScoreParticipations < ActiveRecord::Migration
  def up
    create_sql = PersonParticipation.
        select("person_id, team_id, competition_id, group_score_type_id, discipline, time, position").
        joins(:group_score).
        joins(group_score: :group_score_category).
        joins(group_score: { group_score_category: :group_score_type }).
        to_sql
    self.connection.execute "CREATE OR REPLACE VIEW group_score_participations AS #{create_sql}"
  end

  def down
    self.connection.execute "DROP VIEW IF EXISTS group_score_participations"
  end
end