SELECT o.id AS id,
       o.organization_name,
       o.mlid AS organization_mlid,
       COUNT(DISTINCT CASE WHEN c.id IS NOT NULL AND c.deleted_at IS NULL THEN c.id END)::INT AS chapter_count,
       COUNT(DISTINCT CASE WHEN g.id IS NOT NULL AND g.deleted_at IS NULL THEN g.id END)::INT AS group_count,
       COUNT(DISTINCT CASE WHEN s.id IS NOT NULL AND s.deleted_at IS NULL THEN s.id END)::INT AS student_count,
       o.country,
       o.updated_at,
       o.created_at,
       o.deleted_at
FROM organizations o
    LEFT JOIN chapters c ON c.organization_id = o.id
    LEFT JOIN groups g ON g.chapter_id = c.id
    LEFT JOIN students s ON s.organization_id = o.id
GROUP BY o.id;