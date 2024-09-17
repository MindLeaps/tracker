SELECT	slu.lesson_id 										  	AS lesson_id,
        slu.lesson_date 					     				AS lesson_date,
        gr.id 													AS group_id,
        gr.chapter_id 											AS chapter_id,
        slu.subject_id										    AS subject_id,
        CONCAT(gr.group_name, ' - ', c.chapter_name) 			AS group_chapter_name,
        ROUND(CAST(AVG(average_mark) AS numeric), 2)::FLOAT 	AS average_mark,
        CAST(SUM(grade_count) AS bigint) 						AS grade_count,
        ROUND(CAST(SUM(CASE WHEN grade_count = 0 THEN 0 ELSE 1 END) AS numeric) / COUNT(slu) * 100, 2)::FLOAT as attendance
FROM student_lesson_summaries AS slu
    JOIN groups gr ON slu.group_id = gr.id
    JOIN chapters c ON gr.chapter_id = c.id
WHERE slu.deleted_at IS NULL
GROUP BY slu.lesson_id, gr.id, c.id, slu.subject_id, slu.lesson_date
ORDER BY lesson_date
