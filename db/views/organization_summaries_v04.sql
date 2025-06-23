SELECT o.id AS id,
       o.organization_name,
       o.mlid AS organization_mlid,
       SUM(CASE WHEN c.id IS NOT NULL AND c.deleted_at IS NULL THEN 1 ELSE 0 END)::INT AS chapter_count,
       SUM(CASE WHEN c.id IS NOT NULL AND c.deleted_at IS NULL THEN c.group_count ELSE 0 END)::INT AS group_count,
       SUM(CASE WHEN c.id IS NOT NULL AND c.deleted_at IS NULL THEN c.student_count ELSE 0 END)::INT AS student_count,
       co.country_name AS country_name,
       o.updated_at,
       o.created_at,
       o.deleted_at
FROM organizations o
         LEFT JOIN chapter_summaries c ON c.organization_id = o.id
         LEFT JOIN countries co ON co.id = o.country_id
GROUP BY o.id, co.country_name;
