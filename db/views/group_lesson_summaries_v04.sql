SELECT	  lesson_id,
          lesson_date,
          group_id,
          chapter_id,
          subject_id,
          group_chapter_name,
          round(cast(avg(average_mark) as numeric), 2)::FLOAT as average_mark
FROM (
         SELECT l.id AS lesson_id,
                l.date AS lesson_date,
                gr.id AS group_id,
                gr.chapter_id AS chapter_id,
                s.id AS subject_id,
                CONCAT(gr.group_name, ' - ', c.chapter_name) AS group_chapter_name,
                avg(g.mark)::FLOAT AS average_mark
         FROM students AS st
                  JOIN groups gr ON st.group_id = gr.id
                  JOIN chapters c ON gr.chapter_id = c.id
                  JOIN lessons l ON l.group_id = gr.id
                  JOIN subjects s ON l.subject_id = s.id
                  JOIN grades g ON (g.student_id = st.id AND g.lesson_id = l.id AND g.deleted_at IS NULL)
         GROUP BY l.id, gr.id, c.id, s.id, st.id
     ) as student_lesson_averages
GROUP BY lesson_id, group_id, chapter_id, subject_id, lesson_date, group_chapter_name
ORDER BY lesson_date
