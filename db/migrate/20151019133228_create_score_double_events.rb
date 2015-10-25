class CreateScoreDoubleEvents < ActiveRecord::Migration
  def up
    hb = Score.valid.hb.select(:time, :competition_id, :person_id).no_finals
    hl = Score.valid.hl.select(:time, :competition_id, :person_id).no_finals

    create_sql = "
      SELECT DISTINCT ON (CONCAT(hb_scores.competition_id, '-', hb_scores.person_id))
        hb_scores.person_id,
        hb_scores.competition_id,
        hb_scores.time AS hb,
        hl_scores.time AS hl,
        hb_scores.time + hl_scores.time AS time
      FROM ( #{hb.to_sql} ) AS hb_scores
      INNER JOIN ( #{hl.to_sql} ) AS hl_scores 
         ON hb_scores.competition_id = hl_scores.competition_id
        AND hb_scores.person_id = hl_scores.person_id
      ORDER BY CONCAT(hb_scores.competition_id, '-', hb_scores.person_id) ASC, time
    "
    self.connection.execute "CREATE OR REPLACE VIEW score_double_events AS #{create_sql}"
  end

  def down
    self.connection.execute "DROP VIEW IF EXISTS score_double_events"
  end
end