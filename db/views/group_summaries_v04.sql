SELECT g.id,
       group_name,
       g.deleted_at,
       g.created_at,
       g.chapter_id   AS chapter_id,
       c.chapter_name AS chapter_name,
       o.id 		  AS organization_id,
       o.mlid 		  AS organization_mlid,
       c.mlid 	      AS chapter_mlid,
       g.mlid         AS mlid,
       CONCAT(o.mlid, '-', c.mlid, '-', g.mlid) AS full_mlid,
       organization_name,
       SUM(CASE WHEN (en.active_since <= CURRENT_DATE) AND (en.inactive_since IS NULL OR en.inactive_since >= CURRENT_DATE) AND (s.deleted_at IS NULL) THEN 1 ELSE 0 END) AS student_count
FROM groups g
         LEFT JOIN enrollments en ON g.id = en.group_id
         LEFT JOIN students s ON s.id = en.student_id
         LEFT JOIN chapters c ON g.chapter_id = c.id
         LEFT JOIN organizations o ON c.organization_id = o.id
GROUP BY g.id, c.id, o.id;
