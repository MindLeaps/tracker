SELECT united.*, skill_count
FROM ( SELECT s.id                AS student_id,
              s.group_id          AS group_id,
              s.first_name        AS first_name,
              s.last_name         AS last_name,
              s.deleted_at        AS deleted_at,
              l.id                AS lesson_id,
              l.date              AS lesson_date,
              l.subject_id        AS subject_id,
              round(AVG(mark), 2) AS average_mark,
              COUNT(mark)         AS grade_count
       FROM students s
                JOIN groups g ON g.id = s.group_id
                JOIN enrollments en ON s.id = en.student_id
                JOIN lessons l ON l.group_id = en.group_id
                LEFT JOIN grades ON (grades.student_id = s.id AND grades.lesson_id = l.id AND grades.deleted_at IS NULL)
       WHERE en.active_since < l.date + 1 AND (en.inactive_since IS NULL OR en.inactive_since > l.date - 1)
       GROUP BY s.id, l.id
     ) united JOIN subject_summaries su ON united.subject_id = su.id
