SELECT s.id                AS student_id,
       s.first_name        AS first_name,
       s.last_name         AS last_name,
       s.deleted_at        AS student_deleted_at,
       l.id                AS lesson_id,
       l.date              AS date,
       l.deleted_at        AS lesson_deleted_at,
       l.subject_id        AS subject_id,
       round(avg(mark), 2) AS average_mark,
       count(mark)         AS grade_count,
       coalesce(jsonb_object_agg(skill_id, jsonb_build_object(
                   'mark', mark,
                   'grade_descriptor_id', grade_descriptor_id,
                   'skill_name', skill_name)) FILTER (WHERE skill_name IS NOT NULL), '{}'::jsonb) AS skill_marks
FROM students s
       JOIN enrollments en ON s.id = en.student_id
       JOIN lessons l on en.group_id = l.group_id
       LEFT JOIN grades g on (g.student_id = s.id AND g.lesson_id = l.id AND g.deleted_at IS NULL)
       LEFT JOIN skills sk on sk.id = g.skill_id
WHERE en.active_since <= l.date AND (en.inactive_since IS NULL OR en.inactive_since >= l.date)
GROUP BY s.id, l.id
ORDER BY l.subject_id;
