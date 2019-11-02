SELECT
    l.id AS lesson_id,
    l.uid AS lesson_uid,
    l.date AS lesson_date,
    gr.id AS group_id,
    gr.chapter_id AS chapter_id,
    s.id AS subject_id,
    CONCAT(gr.group_name, ' - ', c.chapter_name) AS group_chapter_name,
    round(avg(g.mark), 2)::FLOAT AS average_mark,
    count(*) AS grade_count
from lessons AS l
         JOIN groups gr ON l.group_id = gr.id
         JOIN grades g ON g.lesson_id = l.id
         JOIN chapters c ON gr.chapter_id = c.id
         JOIN subjects s ON l.subject_id = s.id
WHERE g.deleted_at IS NULL
GROUP BY l.id, gr.id, c.id, s.id
ORDER BY lesson_date;
