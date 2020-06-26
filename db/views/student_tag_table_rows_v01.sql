SELECT t.id, tag_name, shared, organization_id, organization_name, count(st.student_id) as student_count
FROM tags t
    JOIN organizations o on t.organization_id = o.id
    LEFT JOIN student_tags st on t.id = st.tag_id
GROUP BY t.id, organization_id, organization_name;
