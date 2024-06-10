SELECT s.id as student_id,
       s.first_name as first_name,
       s.last_name as last_name,
       s.deleted_at as student_deleted_at,
       l.id as lesson_id,
       l.date as date,
       l.deleted_at as lesson_deleted_at,
       subject_id,
       round(avg(mark), 2) as average_mark,
       count(mark) as grade_count,
       coalesce(jsonb_object_agg(skill_id, jsonb_build_object(
                   'mark', mark,
                   'grade_descriptor_id', grade_descriptor_id,
                   'skill_name', skill_name)) FILTER (WHERE skill_name IS NOT NULL), '{}'::jsonb) as skill_marks
FROM students s
       JOIN groups g on g.id = s.group_id
       JOIN lessons l on g.id = l.group_id
       LEFT JOIN grades on (grades.student_id = s.id AND grades.lesson_id = l.id)
       LEFT JOIN skills on skills.id = skill_id
GROUP BY s.id, l.id
ORDER BY subject_id;
