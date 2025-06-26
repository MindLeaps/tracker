SELECT s.*, g.group_name, o.mlid as organization_mlid, c.mlid as chapter_mlid, g.mlid as group_mlid, CONCAT(o.mlid, '-', s.mlid) as full_mlid
FROM students s
JOIN groups g ON s.group_id = g.id
JOIN chapters c ON g.chapter_id = c.id
JOIN organizations o ON s.organization_id = o.id