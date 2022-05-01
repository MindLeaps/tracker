SELECT c.id as id,
       c.chapter_name,
       c.mlid as chapter_mlid,
       o.mlid as organization_mlid,
       CONCAT(o.mlid, '-', c.mlid) as full_mlid,
       c.organization_id,
       o.organization_name,
       c.deleted_at,
       SUM(case WHEN g.id IS NOT NULL AND g.deleted_at IS NULL THEN 1 ELSE 0 END)::INT as group_count,
       COALESCE(SUM(g.student_count), 0)::INT as student_count, c.created_at, c.updated_at
FROM chapters c LEFT JOIN group_summaries g on chapter_id = c.id LEFT JOIN organizations o on c.organization_id = o.id
GROUP BY c.id, o.id;
