SELECT c.id, c.country_name, count(o.country_id) AS organization_count
FROM countries c
         LEFT JOIN organizations o ON o.country_id = c.id
GROUP BY c.id