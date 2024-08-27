WITH group_student_counts AS (
    SELECT  gr.id AS group_id, group_name, chapter_name,
            COALESCE(count(s.id), 0) as student_count
    FROM groups gr
             LEFT JOIN students s ON s.group_id = gr.id AND s.deleted_at IS NULL
             JOIN chapters c on gr.chapter_id = c.id
    GROUP BY gr.id, chapter_name
)
SELECT l.*, group_name, chapter_name,
       s.subject_name                               AS subject_name,
       student_count                                AS group_student_count,
       COUNT(CASE WHEN grade_count>0 THEN 1 END)    AS graded_student_count,
       ROUND(CAST(AVG(average_mark) AS numeric), 2) AS average_mark
FROM lessons l
         JOIN subjects s ON l.subject_id = s.id
         JOIN group_student_counts sc ON l.group_id = sc.group_id
         JOIN student_lesson_summaries slu
             ON l.subject_id = slu.subject_id AND l.group_id = slu.group_id AND l.date = slu.lesson_date AND slu.deleted_at IS NULL
GROUP BY l.id, subject_name, sc.student_count, group_name, chapter_name
