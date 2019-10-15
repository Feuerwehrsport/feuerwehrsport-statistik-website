SELECT date_part('year'::text, competitions.date) AS YEAR
FROM competitions
GROUP BY (date_part('year'::text, competitions.date))
ORDER BY (date_part('year'::text, competitions.date)) DESC