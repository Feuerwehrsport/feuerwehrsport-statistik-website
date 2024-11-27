SELECT *
FROM
  (SELECT hb_scores.person_id,
          hb_scores.competition_id,
          hb_scores."time" AS hb,
          hb_scores.single_discipline_id AS hb_single_discipline_id,
          hl_scores."time" AS hl,
          hl_scores.single_discipline_id AS hl_single_discipline_id,
          (hb_scores."time" + hl_scores."time") AS "time",
          ROW_NUMBER() OVER (PARTITION BY hb_scores.competition_id,hb_scores.person_id
                             ORDER BY (hb_scores."time" + hl_scores."time")) AS r
   FROM (
           (SELECT scores."time",
                   scores.competition_id,
                   scores.person_id,
                   scores.single_discipline_id
            FROM scores
            INNER JOIN single_disciplines sd ON sd.id = scores.single_discipline_id
            WHERE ((scores."time" <> 99999999)
                   AND ((sd.key) = 'hb')
                   AND (scores.team_number >= 0))) hb_scores
         JOIN
           (SELECT scores."time",
                   scores.competition_id,
                   scores.person_id,
                   scores.single_discipline_id
            FROM scores
            INNER JOIN single_disciplines sd ON sd.id = scores.single_discipline_id
            WHERE ((scores."time" <> 99999999)
                   AND ((sd.key) = 'hl')
                   AND (scores.team_number >= 0))) hl_scores ON (((hb_scores.competition_id = hl_scores.competition_id)
                                                                  AND (hb_scores.person_id = hl_scores.person_id)))) ) AS double_events
WHERE r = 1