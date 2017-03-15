class AddHbfToMultipleTables < ActiveRecord::Migration
  def change
    create_view :score_low_double_events, <<-SQL
      SELECT DISTINCT ON ((concat(hb_scores.competition_id, '-', hb_scores.person_id))) hb_scores.person_id,
        hb_scores.competition_id,
        hb_scores."time" AS hb,
        hl_scores."time" AS hl,
        (hb_scores."time" + hl_scores."time") AS "time"
      FROM (( SELECT scores."time",
                scores.competition_id,
                scores.person_id
               FROM scores
              WHERE ((scores."time" <> 99999999) AND ((scores.discipline)::text = 'hw'::text) AND (scores.team_number >= 0))) hb_scores
         JOIN ( SELECT scores."time",
                scores.competition_id,
                scores.person_id
               FROM scores
              WHERE ((scores."time" <> 99999999) AND ((scores.discipline)::text = 'hl'::text) AND (scores.team_number >= 0))) hl_scores ON (((hb_scores.competition_id = hl_scores.competition_id) AND (hb_scores.person_id = hl_scores.person_id))))
      ORDER BY (concat(hb_scores.competition_id, '-', hb_scores.person_id)), (hb_scores."time" + hl_scores."time")
  SQL

  end
end
