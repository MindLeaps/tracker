SELECT  c.id AS id,
        c.chapter_name,
        c.mlid AS chapter_mlid,
        o.mlid AS organization_mlid,
        CONCAT(o.mlid, '-', c.mlid) AS full_mlid,
        c.organization_id,
        o.organization_name,
        c.deleted_at,
        COUNT(DISTINCT CASE WHEN g.deleted_at IS NULL THEN g.id END)::INT AS group_count,
        COUNT(DISTINCT CASE WHEN (en.active_since <= CURRENT_DATE)
            AND (en.inactive_since IS NULL OR en.inactive_since >= CURRENT_DATE)
            AND (s.deleted_at IS NULL) THEN s.id END)::INT AS student_count,
        c.created_at,
        c.updated_at
FROM chapters c
         LEFT JOIN groups g ON g.chapter_id = c.id
         LEFT JOIN enrollments en ON en.group_id = g.id
         LEFT JOIN students s ON s.id = en.student_id
         LEFT JOIN organizations o ON c.organization_id = o.id
GROUP BY c.id, o.id; 