class Sql
  def self.performance_per_skill_in_lessons_per_student_query(student_ids)
    <<~SQL.squish
      select rank() over(PARTITION BY stu.id, s.id order by date) - 1 as rank, round(avg(mark), 2)::FLOAT, l.id, date, s.skill_name, stu.id::INT from
          lessons as l
              join groups as gr on gr.id = l.group_id
              join grades as g on l.id = g.lesson_id
              join students as stu on stu.id = g.student_id
              join skills as s on s.id = g.skill_id
      WHERE stu.id IN (#{student_ids.join(', ')})
      GROUP BY gr.id, stu.id, l.id, s.id
      ORDER BY stu.id, date, s.id;
    SQL
  end

  def self.student_performance_query(students)
    <<~SQL.squish
      select COALESCE(rounded, 0)::INT as mark, count(*) * 100 / (sum(count(*)) over ())::FLOAT as percentage
        from (select s.id, round(avg(mark)) as rounded
              from students as s
                left join grades as g
                  on s.id = g.student_id
              WHERE s.id IN (#{students.ids.join(', ')}) AND s.deleted_at IS NULL AND g.deleted_at IS NULL
              GROUP BY s.id
        ) as student_round_mark
      GROUP BY mark
      ORDER BY mark;
    SQL
  end

  def self.performance_change_query(students)
    <<~SQL.squish
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
          WHERE s.id IN (#{students.ids.join(', ')}) AND g.deleted_at IS NULL AND s.deleted_at IS NULL
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

  def self.average_mark_in_group_lessons(group)
    <<~SQL.squish
      select row_number() over (ORDER BY date) - 1, round(avg(mark), 2)::FLOAT, l.id, date from lessons as l
        join grades as g on g.lesson_id = l.id
      where group_id = #{group.id} AND g.deleted_at IS NULL
      group by l.id;
    SQL
  end

  def self.performance_in_student_lessons(student_id, from = '1970-01-01', to = 'current_date')
    <<~SQL.squish
        SELECT s.id               AS student_id,
               l.group_id          AS group_id,
               s.first_name        AS first_name,
               s.last_name         AS last_name,
               g.group_name        AS group_name,
               l.id                AS lesson_id,
               l.date              AS lesson_date,
               round(AVG(mark), 2) AS average_mark,
               COUNT(mark)		  AS grade_count,
               CASE WHEN COUNT(mark) > 0 THEN true ELSE false END AS attendance
          FROM students s
          JOIN enrollments en ON s.id = en.student_id
          JOIN groups g ON g.id = en.group_id
          JOIN lessons l ON l.group_id = g.id
          LEFT JOIN grades ON (grades.student_id = s.id AND grades.lesson_id = l.id AND grades.deleted_at IS NULL)
      WHERE en.active_since <= l.date AND (en.inactive_since IS NULL OR en.inactive_since >= l.date) AND s.id = #{student_id} AND l.date BETWEEN '#{from}' AND '#{to}'
      GROUP BY s.id, l.id, g.id
      ORDER BY g.id, lesson_date
    SQL
  end

  def self.performance_in_group_lessons(groups, from = '1970-01-01', to = 'current_date')
    <<~SQL.squish
        SELECT g.id                AS group_id,
               g.group_name        AS group_name,
               CONCAT(g.group_name, ' - ', c.chapter_name) 	AS group_chapter_name,
               l.id                AS lesson_id,
               l.date              AS lesson_date,
               round(AVG(mark), 2) AS average_mark,
               COUNT(mark)		     AS grade_count,
               ROUND(COUNT(DISTINCT(gr.student_id))::numeric / COUNT(DISTINCT(en.student_id)) * 100, 2)::FLOAT AS attendance
        FROM groups g
        JOIN enrollments en ON g.id = en.group_id
        JOIN chapters c ON g.chapter_id = c.id
        JOIN lessons l ON l.group_id = g.id
        LEFT JOIN grades gr ON (gr.student_id = en.student_id AND gr.lesson_id = l.id AND gr.deleted_at IS NULL)
      WHERE en.active_since <= l.date AND (en.inactive_since IS NULL OR en.inactive_since >= l.date) AND g.id IN (#{groups.length.positive? ? groups.join(', ') : 'null'}) AND l.date BETWEEN '#{from}' AND '#{to}'
      GROUP BY g.id, l.id, c.id, l.date
      ORDER BY lesson_date
    SQL
  end
end
