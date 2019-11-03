SELECT l.uid as lesson_uid, sk.id as skill_id, skill_name, round(avg(mark), 2) as average_mark, count(mark) as grade_count FROM
    lessons l JOIN subjects su on su.id = l.subject_id
        JOIN assignments a ON su.id = a.subject_id JOIN skills sk ON a.skill_id = sk.id
        LEFT JOIN grades g ON (g.lesson_uid = l.uid AND g.skill_id = sk.id)
WHERE g.deleted_at IS NULL
GROUP BY l.uid, sk.id
