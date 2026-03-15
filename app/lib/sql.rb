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

  def self.performance_change_summary_with_middle_by_subject_query(student_ids)
    <<~SQL.squish
    WITH lesson_averages AS (
      SELECT
        s.id AS student_id,
        sub.id AS subject_id,
        sub.subject_name AS subject_name,
        l.id AS lesson_id,
        l.date AS lesson_date,
        AVG(g.mark) AS average_mark
      FROM students s
      JOIN grades g ON s.id = g.student_id
      JOIN lessons l ON l.id = g.lesson_id
      JOIN subjects sub ON sub.id = l.subject_id
      WHERE s.id IN (#{student_ids.join(', ')})
        AND g.deleted_at IS NULL
        AND s.deleted_at IS NULL
        AND l.deleted_at IS NULL
        AND sub.deleted_at IS NULL
      GROUP BY s.id, sub.id, sub.subject_name, l.id, l.date
    ),
    ranked_lessons AS (
      SELECT
        lesson_averages.*,
        COUNT(*) OVER (PARTITION BY student_id, subject_id) AS lesson_count,
        ROW_NUMBER() OVER (
          PARTITION BY student_id, subject_id
          ORDER BY lesson_date ASC, lesson_id ASC
        ) AS row_num
      FROM lesson_averages
    ),
    first_lessons AS (
      SELECT
        student_id,
        subject_id,
        subject_name,
        lesson_date AS first_date,
        average_mark AS first_avg,
        lesson_count
      FROM ranked_lessons
      WHERE row_num = 1
        AND lesson_count >= 10
    ),
    middle_lessons AS (
      SELECT
        student_id,
        subject_id,
        lesson_date AS middle_date,
        average_mark AS middle_avg
      FROM ranked_lessons
      WHERE row_num = ((lesson_count + 1) / 2)
        AND lesson_count >= 10
    ),
    last_lessons AS (
      SELECT
        student_id,
        subject_id,
        lesson_date AS last_date,
        average_mark AS last_avg
      FROM ranked_lessons
      WHERE row_num = lesson_count
        AND lesson_count >= 10
    )
    SELECT
      first_lessons.student_id,
      first_lessons.subject_id,
      first_lessons.subject_name,
      first_lessons.lesson_count,

      first_lessons.first_date,
      ROUND(first_lessons.first_avg::numeric, 2) AS first_avg,

      middle_lessons.middle_date,
      ROUND(middle_lessons.middle_avg::numeric, 2) AS middle_avg,

      last_lessons.last_date,
      ROUND(last_lessons.last_avg::numeric, 2) AS last_avg,

      ROUND((middle_lessons.middle_avg - first_lessons.first_avg)::numeric, 2) AS first_to_middle_diff,
      ROUND((last_lessons.last_avg - middle_lessons.middle_avg)::numeric, 2) AS middle_to_last_diff,
      ROUND((last_lessons.last_avg - first_lessons.first_avg)::numeric, 2) AS overall_diff
    FROM first_lessons
    JOIN middle_lessons
      ON middle_lessons.student_id = first_lessons.student_id
     AND middle_lessons.subject_id = first_lessons.subject_id
    JOIN last_lessons
      ON last_lessons.student_id = first_lessons.student_id
     AND last_lessons.subject_id = first_lessons.subject_id
    ORDER BY first_lessons.subject_name
  SQL
  end
end
