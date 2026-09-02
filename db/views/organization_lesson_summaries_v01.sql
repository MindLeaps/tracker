SELECT l.id AS lesson_id,
       l.date AS lesson_date,
       gr.id AS group_id,
       gr.chapter_id,
       c.organization_id,
       l.subject_id,
       CONCAT(gr.group_name, ' - ', c.chapter_name) AS group_chapter_name,
       (
           SELECT COUNT(g.mark)::BIGINT
           FROM grades g
               JOIN students s
                 ON s.id = g.student_id
                AND s.deleted_at IS NULL
           WHERE g.lesson_id = l.id
             AND g.deleted_at IS NULL
             AND EXISTS (
                 SELECT 1
                 FROM enrollments en
                 WHERE en.group_id = l.group_id
                   AND en.student_id = g.student_id
                   AND en.active_since <= l.date
                   AND (en.inactive_since IS NULL OR en.inactive_since >= l.date)
             )
       ) AS grade_count
FROM lessons l
    JOIN groups gr ON gr.id = l.group_id
    JOIN chapters c ON c.id = gr.chapter_id
WHERE EXISTS (
    SELECT 1
    FROM enrollments en
        JOIN students s
          ON s.id = en.student_id
         AND s.deleted_at IS NULL
    WHERE en.group_id = l.group_id
      AND en.active_since <= l.date
      AND (en.inactive_since IS NULL OR en.inactive_since >= l.date)
);
