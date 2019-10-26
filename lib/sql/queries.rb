module SQL
  def performance_per_skill_in_lessons_query(lessons)
    <<~SQL
      select rank() over(PARTITION BY gr.id, s.id order by date) - 1 as rank, round(avg(mark), 2)::FLOAT, l.id, date, s.skill_name, gr.id::INT from
          lessons as l
          join groups as gr on gr.id = l.group_id
          join grades as g on l.id = g.lesson_id
          join skills as s on s.id = g.skill_id
        WHERE l.id IN (#{lessons.pluck(:id).join(', ')})
        GROUP BY gr.id, l.id, s.id
        ORDER BY gr.id, date, s.id;
    SQL
  end

  def student_performance_query(students)
    <<~SQL
      select COALESCE(rounded, 0)::INT as mark, count(*) * 100 / (sum(count(*)) over ())::FLOAT as percentage
        from (select s.id, round(avg(mark)) as rounded
              from students as s
                left join grades as g
                  on s.id = g.student_id
              WHERE s.id IN (#{students.pluck(:id).join(', ')}) AND s.deleted_at IS NULL AND g.deleted_at IS NULL
              GROUP BY s.id
        ) as student_round_mark
      GROUP BY mark
      ORDER BY mark;
    SQL
  end

  def performance_change_query(students)
    <<~SQL
      with w1 AS (
          SELECT
            s.id as student_id,
            l.id as lesson_id,
            date,
            avg(mark),
            count(*) over (partition by s.id) as lesson_count
          FROM students AS s
            JOIN grades AS g
              ON s.id = g.student_id
            JOIN lessons AS l
              ON l.id = g.lesson_id
          WHERE s.id IN (#{students.pluck(:id).join(', ')}) AND g.deleted_at IS NULL AND s.deleted_at IS NULL
          GROUP BY s.id, l.id
      ),
      min_table AS (
          SELECT * from w1 s1 WHERE ((student_id, date) IN (
            SELECT student_id, MIN(date) FROM w1
            GROUP BY student_id
          ) OR date is null) AND lesson_count >= 10
      ),
      max_table AS (
        SELECT * from w1 s1 WHERE ((student_id, date) IN (
          SELECT student_id, MAX(date) FROM w1
          GROUP BY student_id
        ) OR date is null) AND lesson_count >= 10
      )
      SELECT COALESCE(floor(((max_table.avg - min_table.avg) * 2) + 0.5) / 2, 0)::FLOAT as diff, count(*) * 100 / (SUM(count(*)) over ())::FLOAT FROM max_table
        JOIN min_table
        ON max_table.student_id = min_table.student_id
      GROUP BY diff
      ORDER BY diff;
    SQL
  end

  def average_mark_in_group_lessons(group)
    <<~SQL
      select row_number() over (ORDER BY date) - 1, round(avg(mark), 2)::FLOAT from lessons as l
        join grades as g on g.lesson_id = l.id
      where group_id = #{group.id} AND g.deleted_at IS NULL
      group by l.id;
    SQL
  end
end
