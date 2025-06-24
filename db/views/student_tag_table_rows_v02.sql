SELECT t.id, tag_name, shared, organization_id, organization_name,
       count(st.student_id) AS student_count,
       c.country_name       AS country_name
FROM tags t
         JOIN organizations o ON t.organization_id = o.id
         LEFT JOIN student_tags st ON t.id = st.tag_id
         LEFT JOIN countries c ON o.country_id = c.id
GROUP BY t.id, organization_id, organization_name, c.country_name;
