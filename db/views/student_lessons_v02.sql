SELECT s.id AS student_id, l.id AS lesson_id
FROM lessons l
         JOIN enrollments en ON l.group_id = en.group_id
         JOIN students s ON s.id = en.student_id;