SELECT s.*, g.group_name, CONCAT(o.mlid, '-', c.mlid, '-', s.mlid) as full_mlid
FROM students s
JOIN groups g ON s.group_id = g.id
JOIN chapters c ON g.chapter_id = c.id
JOIN organizations o ON c.organization_id = o.id