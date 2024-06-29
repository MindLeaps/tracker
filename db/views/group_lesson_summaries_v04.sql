SELECT	  l.id AS lesson_id,
            l.date AS lesson_date,
            gr.id AS group_id,
            gr.chapter_id AS chapter_id,
            slu.subject_id,
            CONCAT(gr.group_name, ' - ', c.chapter_name) AS group_chapter_name,
            ROUND(CAST(AVG(average_mark) AS numeric), 2)::FLOAT AS average_mark,
            CAST(SUM(grade_count) AS bigint) AS grade_count
FROM lessons AS l
         JOIN groups gr ON l.group_id = gr.id
         JOIN chapters c ON gr.chapter_id = c.id
         JOIN student_lesson_summaries slu ON l.subject_id = slu.subject_id AND l.group_id = slu.group_id AND l.date = slu.lesson_date
WHERE slu.deleted_at IS NULL
GROUP BY l.id, gr.id, c.id, slu.subject_id
ORDER BY lesson_date
