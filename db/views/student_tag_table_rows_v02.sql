SELECT t.id, tag_name, shared, organization_id, organization_name, count(st.student_id) AS student_count, o.country
FROM tags t
    JOIN organizations o ON t.organization_id = o.id
    LEFT JOIN student_tags st ON t.id = st.tag_id
GROUP BY t.id, organization_id, organization_name, o.country;
