SELECT s.id                  AS student_id,
       s.first_name          AS first_name,
       s.last_name           AS last_name,
       s.deleted_at          AS student_deleted_at,
       su.id                 AS subject_id,
       su.subject_name       AS subject_name,
       sk.skill_name         AS skill_name,
       ROUND(AVG(g.mark), 2) AS average_mark
FROM students s
         JOIN grades g ON (g.student_id = s.id AND g.deleted_at IS NULL)
         JOIN skills sk ON sk.id = g.skill_id
         JOIN assignments a ON a.skill_id = sk.id
         JOIN subjects su ON su.id = a.subject_id
         JOIN lessons l ON l.id = g.lesson_id AND l.subject_id = su.id
GROUP BY s.id, su.id, sk.skill_name
