WITH lesson_summary_stats AS (
    SELECT slu.lesson_id,
           COUNT(*)                                        AS group_student_count,
           COUNT(*) FILTER (WHERE slu.grade_count > 0)     AS graded_student_count,
           ROUND(AVG(slu.average_mark)::numeric, 2)        AS average_mark
    FROM student_lesson_summaries slu
    WHERE slu.deleted_at IS NULL
    GROUP BY slu.lesson_id
)
SELECT l.*,
       gr.group_name,
       c.chapter_name,
       s.subject_name AS subject_name,
       lss.group_student_count,
       lss.graded_student_count,
       lss.average_mark
FROM lessons l
         JOIN lesson_summary_stats lss ON l.id = lss.lesson_id
         JOIN groups gr ON l.group_id = gr.id
         JOIN chapters c ON gr.chapter_id = c.id
         JOIN subjects s ON l.subject_id = s.id
