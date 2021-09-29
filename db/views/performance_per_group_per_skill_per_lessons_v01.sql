select gr.id as group_id, gr.group_name as group_name, gr.group_name || ' - ' || c.chapter_name as group_chapter_name, l.id as lesson_id, date, s.id as skill_id, s.skill_name, su.id as subject_id, round(avg(mark), 2)::FLOAT as mark from
    groups as gr
        join chapters c on gr.chapter_id = c.id
        join lessons l on gr.id = l.group_id
        join subjects su on l.subject_id = su.id
        join grades as g on l.id = g.lesson_id
        join skills as s on s.id = g.skill_id
GROUP BY gr.id, c.id, l.id, s.id, su.id
ORDER BY gr.id, date, s.id;
