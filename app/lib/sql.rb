class Sql
  def self.performance_per_skill_in_lessons_per_student_query_with_dates(student_ids)
    <<~SQL.squish
      select
        rank() over(PARTITION BY stu.id, s.id order by l.date) - 1 as rank,
        round(avg(g.mark), 2)::FLOAT,
        l.id,
        l.date,
        s.skill_name,
        stu.id::INT
      from lessons l
        join groups gr on gr.id = l.group_id
        join grades g on l.id = g.lesson_id
        join students stu on stu.id = g.student_id
        join skills s on s.id = g.skill_id
      WHERE stu.id IN (#{student_ids.join(', ')})
        AND g.deleted_at IS NULL
        AND stu.deleted_at IS NULL
        AND ($1::date IS NULL OR l.date >= $1::date)
        AND ($2::date IS NULL OR l.date <= $2::date)
      GROUP BY gr.id, stu.id, l.id, s.id, l.date, s.skill_name
      ORDER BY stu.id, l.date, s.id;
    SQL
  end

  def self.average_mark_for_group_lessons
    <<~SQL.squish
      SELECT
        row_number() OVER (ORDER BY l.date) - 1 AS idx,
        round(avg(g.mark), 2)::FLOAT AS avg_mark,
        l.id AS lesson_id,
        l.date AS lesson_date
      FROM lessons l
      JOIN grades g ON g.lesson_id = l.id
      WHERE l.group_id = $1
        AND g.deleted_at IS NULL
        AND ($2::date IS NULL OR l.date >= $2::date)
        AND ($3::date IS NULL OR l.date <= $3::date)
      GROUP BY l.id, l.date
      ORDER BY l.date;
    SQL
  end

  def self.student_performance_query_with_dates(student_ids)
    <<~SQL.squish
      select COALESCE(rounded, 0)::INT as mark, count(*) * 100 / (sum(count(*)) over ())::FLOAT as percentage
      from (
        select s.id, round(avg(g.mark)) as rounded
        from students s
        left join grades g on s.id = g.student_id and g.deleted_at IS NULL
        left join lessons l on l.id = g.lesson_id
        WHERE s.id IN (#{student_ids.join(', ')}) AND s.deleted_at IS NULL
          and ($1::date IS NULL OR l.date >= $1::date)
          and ($2::date IS NULL OR l.date <= $2::date)
        GROUP BY s.id
      ) as student_round_mark
      GROUP BY mark
      ORDER BY mark;
    SQL
  end

  def self.performance_change_query_with_dates(student_ids)
    <<~SQL.squish
      with w1 AS (
        SELECT
          s.id as student_id,
          l.id as lesson_id,
          l.date as date,
          avg(g.mark) as avg,
          count(*) over (partition by s.id) as lesson_count
        FROM students s
        JOIN grades g ON s.id = g.student_id
        JOIN lessons l ON l.id = g.lesson_id
        WHERE s.id IN (#{student_ids.join(', ')})
          AND g.deleted_at IS NULL
          AND s.deleted_at IS NULL
          AND ($1::date IS NULL OR l.date >= $1::date)
          AND ($2::date IS NULL OR l.date <= $2::date)
        GROUP BY s.id, l.id, l.date
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
      SELECT
        COALESCE(floor(((max_table.avg - min_table.avg) * 2) + 0.5) / 2, 0)::FLOAT as diff,
        count(*) * 100 / (SUM(count(*)) over ())::FLOAT
      FROM max_table
      JOIN min_table ON max_table.student_id = min_table.student_id
      GROUP BY diff
      ORDER BY diff;
    SQL
  end
end
