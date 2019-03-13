SELECT s.id AS student_id, l.id AS lesson_id
FROM lessons l JOIN groups g ON l.group_id = g.id JOIN students s ON g.id = s.group_id;