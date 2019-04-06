SELECT s.id as student_id,
       s.first_name as first_name,
       s.last_name as last_name,
       s.deleted_at as deleted_at,
       l.id as lesson_id,
       round(avg(mark), 2) as average_mark,
       count(mark) as grade_count,
       (CASE WHEN a.id IS NULL THEN FALSE ELSE TRUE END) as absent
FROM students s
            JOIN groups g on g.id = s.group_id
            JOIN lessons l on g.id = l.group_id
            LEFT JOIN grades on (grades.student_id = s.id AND grades.lesson_id = l.id)
            LEFT JOIN absences a on (a.student_id = s.id AND a.lesson_id = l.id)
GROUP BY s.id, l.id, a.id
ORDER BY last_name;
