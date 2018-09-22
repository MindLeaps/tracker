SELECT g.id,
       group_name,
       g.deleted_at,
       g.chapter_id as chapter_id,
       c.chapter_name as chapter_name,
       o.id as organization_id,
       organization_name,
       SUM(case WHEN s.id IS NOT NULL AND s.deleted_at IS NULL THEN 1 ELSE 0 END) as student_count
FROM groups g LEFT JOIN students s on g.id = s.group_id
              LEFT JOIN chapters c on g.chapter_id = c.id
              LEFT JOIN organizations o on c.organization_id = o.id
GROUP BY g.id, c.id, o.id;
