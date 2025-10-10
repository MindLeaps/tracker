SELECT s.id, s.first_name, s.last_name, s.old_group_id, COALESCE(array_agg(en.group_id) FILTER (WHERE en.group_id IS NOT NULL), '{}') AS enrolled_group_ids
FROM students s
         JOIN organizations o ON s.organization_id = o.id
         JOIN enrollments en ON s.id = en.student_id
WHERE s.deleted_at IS NULL
GROUP BY s.id, s.first_name, s.last_name
ORDER BY s.last_name ASC, s.first_name ASC