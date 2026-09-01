WITH chapter_counts AS (
    SELECT organization_id,
           COUNT(*) FILTER (WHERE deleted_at IS NULL)::INT AS chapter_count
    FROM chapters
    GROUP BY organization_id
),
group_counts AS (
    SELECT c.organization_id,
           COUNT(*) FILTER (WHERE g.id IS NOT NULL AND g.deleted_at IS NULL)::INT AS group_count
    FROM chapters c
        LEFT JOIN groups g ON g.chapter_id = c.id
    GROUP BY c.organization_id
),
student_counts AS (
    SELECT organization_id,
           COUNT(*) FILTER (WHERE deleted_at IS NULL)::INT AS student_count
    FROM students
    GROUP BY organization_id
)
SELECT o.id,
       o.organization_name,
       o.mlid AS organization_mlid,
       COALESCE(cc.chapter_count, 0)::INT AS chapter_count,
       COALESCE(gc.group_count, 0)::INT AS group_count,
       COALESCE(sc.student_count, 0)::INT AS student_count,
       o.country,
       o.updated_at,
       o.created_at,
       o.deleted_at
FROM organizations o
    LEFT JOIN chapter_counts cc ON cc.organization_id = o.id
    LEFT JOIN group_counts gc ON gc.organization_id = o.id
    LEFT JOIN student_counts sc ON sc.organization_id = o.id;
