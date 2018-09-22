WITH group_student_count as (
    SELECT g.id as group_id,
           group_name,
           g.deleted_at,
           g.chapter_id as chapter_id,
           SUM(case WHEN s.id IS NOT NULL AND s.deleted_at IS NULL THEN 1 ELSE 0 END) as student_count
    FROM groups g LEFT JOIN students s on g.id = s.group_id
    WHERE (g.deleted_at IS NULL)
    GROUP BY g.id
)
SELECT c.id as id,
       chapter_name,
       c.organization_id,
       organization_name,
       c.deleted_at,
       count(group_id) as group_count,
       COALESCE(SUM(student_count), 0)::INT as student_count, c.created_at, c.updated_at
FROM chapters c LEFT JOIN group_student_count on chapter_id = c.id LEFT JOIN organizations o on c.organization_id = o.id
GROUP BY c.id, o.id;
