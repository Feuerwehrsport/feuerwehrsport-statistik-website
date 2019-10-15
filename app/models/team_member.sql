SELECT group_scores.team_id,
       person_participations.person_id
FROM (group_scores
      JOIN person_participations ON ((person_participations.group_score_id = group_scores.id)))
UNION
SELECT scores.team_id,
       scores.person_id
FROM scores
WHERE (scores.team_id IS NOT NULL)