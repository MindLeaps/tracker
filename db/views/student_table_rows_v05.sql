SELECT s.*, g.group_name, o.mlid AS organization_mlid, c.mlid AS chapter_mlid, g.mlid AS group_mlid, CONCAT(o.mlid, '-', s.mlid) AS full_mlid
FROM students s
         JOIN enrollments en ON s.id = en.student_id
         JOIN groups g ON g.id = en.group_id
         JOIN chapters c ON g.chapter_id = c.id
         JOIN organizations o ON s.organization_id = o.id