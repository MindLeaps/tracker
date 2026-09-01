WITH lesson_enrollment_stats AS (
    SELECT l.group_id,
           l.id AS lesson_id,
           COUNT(DISTINCT s.id) AS student_count
    FROM lessons l
        JOIN enrollments en
          ON en.group_id = l.group_id
         AND en.active_since <= l.date
         AND (en.inactive_since IS NULL OR en.inactive_since >= l.date)
        JOIN students s
          ON s.id = en.student_id
         AND s.deleted_at IS NULL
    GROUP BY l.group_id, l.id
),
student_grade_stats AS (
    SELECT l.group_id,
           l.id AS lesson_id,
           gr.student_id,
           ROUND(AVG(gr.mark), 2) AS average_mark,
           COUNT(gr.mark) AS grade_count
    FROM lessons l
        JOIN grades gr
          ON gr.lesson_id = l.id
         AND gr.deleted_at IS NULL
        JOIN students s
          ON s.id = gr.student_id
         AND s.deleted_at IS NULL
    WHERE EXISTS (
        SELECT 1
        FROM enrollments en
        WHERE en.group_id = l.group_id
          AND en.student_id = gr.student_id
          AND en.active_since <= l.date
          AND (en.inactive_since IS NULL OR en.inactive_since >= l.date)
    )
    GROUP BY l.group_id, l.id, gr.student_id
),
lesson_grade_stats AS (
    SELECT group_id,
           lesson_id,
           ROUND(AVG(average_mark)::NUMERIC, 2)::FLOAT AS average_mark,
           SUM(grade_count)::BIGINT AS grade_count,
           COUNT(*) AS graded_student_count
    FROM student_grade_stats
    GROUP BY group_id, lesson_id
)
SELECT l.id AS lesson_id,
       l.date AS lesson_date,
       gr.id AS group_id,
       gr.chapter_id,
       l.subject_id,
       CONCAT(gr.group_name, ' - ', c.chapter_name) AS group_chapter_name,
       lgs.average_mark,
       COALESCE(lgs.grade_count, 0)::BIGINT AS grade_count,
       ROUND(
           COALESCE(lgs.graded_student_count, 0)::NUMERIC / les.student_count * 100,
           2
       )::FLOAT AS attendance
FROM lessons l
    JOIN groups gr ON gr.id = l.group_id
    JOIN chapters c ON c.id = gr.chapter_id
    JOIN lesson_enrollment_stats les
      ON les.lesson_id = l.id
     AND les.group_id = gr.id
    LEFT JOIN lesson_grade_stats lgs
      ON lgs.lesson_id = l.id
     AND lgs.group_id = gr.id;
