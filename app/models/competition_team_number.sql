SELECT group_scores.team_id,
       group_scores.team_number,
       group_scores.gender,
       group_score_categories.competition_id
FROM (group_scores
      JOIN group_score_categories ON ((group_score_categories.id = group_scores.group_score_category_id)))
WHERE (group_scores.team_number > 0)
UNION
SELECT scores.team_id,
       scores.team_number,
       people.gender,
       scores.competition_id
FROM (scores
      JOIN people ON ((people.id = scores.person_id)))
WHERE ((scores.team_number > 0)
       AND (scores.team_id IS NOT NULL))