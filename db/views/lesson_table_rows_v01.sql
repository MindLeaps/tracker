WITH group_student_counts AS (
    SELECT gr.id AS group_id, group_name, chapter_name, COALESCE(count(s.id), 0) as student_count FROM groups gr
        LEFT JOIN students s ON s.group_id = gr.id AND s.deleted_at IS NULL
        JOIN chapters c on gr.chapter_id = c.id
    GROUP BY gr.id, chapter_name
)
SELECT l.*, group_name, chapter_name, subject_name, student_count AS group_student_count, COUNT(DISTINCT(g.student_id)) as graded_student_count FROM lessons l
   JOIN subjects su ON l.subject_id = su.id
   LEFT JOIN grades g ON l.id = g.lesson_id AND g.deleted_at IS NULL
   JOIN group_student_counts sc on l.group_id = sc.group_id
GROUP BY l.id, subject_name, sc.student_count, group_name, chapter_name;
