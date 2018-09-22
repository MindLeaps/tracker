SELECT o.id as id,
       organization_name,
       SUM(CASE WHEN c.id IS NOT NULL AND c.deleted_at IS NULL THEN 1 ELSE 0 END) as chapter_count,
       o.updated_at,
       o.created_at
FROM organizations o LEFT JOIN chapters c on c.organization_id = o.id
GROUP BY o.id;
