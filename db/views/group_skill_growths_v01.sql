WITH eligible_grades AS (
    SELECT l.group_id,
           gr.student_id,
           gr.skill_id,
           sk.skill_name,
           gr.mark,
           l.date AS lesson_date,
           l.id AS lesson_id,
           gr.id AS grade_id
    FROM grades gr
        JOIN lessons l
          ON l.id = gr.lesson_id
         AND l.deleted_at IS NULL
        JOIN students s
          ON s.id = gr.student_id
         AND s.deleted_at IS NULL
        JOIN skills sk ON sk.id = gr.skill_id
    WHERE gr.deleted_at IS NULL
      AND EXISTS (
          SELECT 1
          FROM enrollments current_enrollment
          WHERE current_enrollment.group_id = l.group_id
            AND current_enrollment.student_id = gr.student_id
            AND current_enrollment.active_since <= CURRENT_DATE
            AND (
                current_enrollment.inactive_since IS NULL
                OR current_enrollment.inactive_since > CURRENT_DATE
            )
      )
      AND EXISTS (
          SELECT 1
          FROM enrollments grade_enrollment
          WHERE grade_enrollment.group_id = l.group_id
            AND grade_enrollment.student_id = gr.student_id
            AND grade_enrollment.active_since <= l.date
            AND (
                grade_enrollment.inactive_since IS NULL
                OR grade_enrollment.inactive_since >= l.date
            )
      )
),
ranked_grades AS (
    SELECT eligible_grades.*,
           ROW_NUMBER() OVER (
               PARTITION BY group_id, student_id, skill_id
               ORDER BY lesson_date, lesson_id, grade_id
           ) AS first_rank,
           ROW_NUMBER() OVER (
               PARTITION BY group_id, student_id, skill_id
               ORDER BY lesson_date DESC, lesson_id DESC, grade_id DESC
           ) AS last_rank
    FROM eligible_grades
),
student_skill_growths AS (
    SELECT group_id,
           student_id,
           skill_id,
           MAX(skill_name) AS skill_name,
           MAX(mark) FILTER (WHERE first_rank = 1) AS first_mark,
           MAX(mark) FILTER (WHERE last_rank = 1) AS last_mark,
           COUNT(*) AS grade_count
    FROM ranked_grades
    GROUP BY group_id, student_id, skill_id
)
SELECT group_id,
       skill_id,
       MAX(skill_name) AS skill_name,
       AVG((last_mark - first_mark)::NUMERIC) AS growth
FROM student_skill_growths
WHERE grade_count >= 2
GROUP BY group_id, skill_id;
