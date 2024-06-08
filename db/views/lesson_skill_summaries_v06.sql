SELECT l.id as lesson_id, sk.id as skill_id, skill_name, round(avg(mark), 2) as average_mark, count(mark) as grade_count, su.id as subject_id FROM
    lessons l JOIN subjects su on su.id = l.subject_id
              JOIN assignments a ON (su.id = a.subject_id and a.deleted_at IS NULL)
              JOIN skills sk ON a.skill_id = sk.id
              LEFT JOIN grades g ON (g.lesson_id = l.id AND g.skill_id = sk.id AND g.deleted_at IS NULL)
GROUP BY l.id, sk.id, su.id
