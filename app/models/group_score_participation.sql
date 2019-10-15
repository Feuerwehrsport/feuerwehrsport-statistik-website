SELECT person_participations.person_id,
       group_scores.team_id,
       group_scores.team_number,
       group_score_categories.competition_id,
       group_score_categories.group_score_type_id,
       group_score_types.discipline,
       group_scores."time",
       person_participations."position"
FROM (((person_participations
        JOIN group_scores ON ((group_scores.id = person_participations.group_score_id)))
       JOIN group_score_categories ON ((group_score_categories.id = group_scores.group_score_category_id)))
      JOIN group_score_types ON ((group_score_types.id = group_score_categories.group_score_type_id)))