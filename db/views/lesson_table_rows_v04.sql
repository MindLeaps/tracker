SELECT l.*, group_name, chapter_name,
       s.subject_name                                 AS subject_name,
       COUNT(DISTINCT(l.id, slu.student_id))		  AS group_student_count,
       COUNT(CASE WHEN grade_count > 0 THEN 1 END)    AS graded_student_count,
       ROUND(CAST(AVG(average_mark) AS numeric), 2)   AS average_mark
FROM lessons l
         JOIN groups gr ON l.group_id = gr.id
         JOIN chapters c on gr.chapter_id = c.id
         JOIN subjects s ON l.subject_id = s.id
         JOIN student_lesson_summaries slu ON l.id = slu.lesson_id AND slu.deleted_at IS NULL
GROUP BY l.id, subject_name, group_name, chapter_name
