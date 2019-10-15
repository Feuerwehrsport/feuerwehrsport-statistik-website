SELECT group_scores.team_id,
       group_score_categories.competition_id
FROM (group_scores
      JOIN group_score_categories ON ((group_score_categories.id = group_scores.group_score_category_id)))
UNION
SELECT scores.team_id,
       scores.competition_id
FROM scores
WHERE (scores.team_id IS NOT NULL)