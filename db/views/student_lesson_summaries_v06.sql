SELECT united.*, skill_count
FROM (
         SELECT s.id                                              as student_id,
                s.group_id                                        as group_id,
                s.first_name                                      as first_name,
                s.last_name                                       as last_name,
                s.deleted_at                                      as deleted_at,
                l.id                                              as lesson_id,
                l.date                                            as lesson_date,
                l.subject_id as subject_id,
                round(avg(mark), 2)                               as average_mark,
                count(mark)                                       as grade_count
         FROM students s
                  JOIN groups g on g.id = s.group_id
                  JOIN lessons l on g.id = l.group_id
                  LEFT JOIN grades on (grades.student_id = s.id AND grades.lesson_id = l.id AND grades.deleted_at IS NULL)
         GROUP BY s.id, l.id
         UNION
         SELECT s.id                                              as student_id,
                s.group_id                                        as group_id,
                s.first_name                                      as first_name,
                s.last_name                                       as last_name,
                s.deleted_at                                      as deleted_at,
                l.id                                              as lesson_id,
                l.date                                            as lesson_date,
                l.subject_id as subject_id,
                round(avg(mark), 2)                               as average_mark,
                count(mark)                                       as grade_count
         FROM lessons l
                  JOIN groups g on g.id = l.group_id
                  JOIN grades on (grades.lesson_id = l.id AND grades.deleted_at IS NULL)
                  JOIN students s on grades.student_id = s.id
         GROUP BY s.id, l.id
     ) united join subject_summaries su on united.subject_id = su.id
