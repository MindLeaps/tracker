SELECT o.id as id,
       o.organization_name,
       o.mlid as organization_mlid,
       SUM(CASE WHEN c.id IS NOT NULL AND c.deleted_at IS NULL THEN 1 ELSE 0 END)::INT as chapter_count,
       SUM(CASE WHEN c.id IS NOT NULL AND c.deleted_at IS NULL THEN c.group_count ELSE 0 END)::INT as group_count,
       SUM(CASE WHEN c.id IS NOT NULL AND c.deleted_at IS NULL THEN c.student_count ELSE 0 END)::INT as student_count,
       o.updated_at,
       o.created_at,
       o.deleted_at
FROM organizations o LEFT JOIN chapter_summaries c on c.organization_id = o.id
GROUP BY o.id;
