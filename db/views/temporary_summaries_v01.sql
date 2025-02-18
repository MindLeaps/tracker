with
    -- Find student info and group summaries
    student_group_summaries as (
        select concat(o.mlid, '-', c.mlid, '-', g.mlid, '-', s.mlid) as full_mlid, s.id as student_id, dob, gender, country_of_nationality, g.group_name as group_name,
               g.id as group_id, min(gls.lesson_date) as first_group_lesson, max(gls.lesson_date) as last_group_lesson, count(gls.lesson_date) as number_of_lessons_for_group
        from students s
                 join group_lesson_summaries gls on gls.group_id = s.group_id
                 join groups g on g.id = gls.group_id
                 join chapters c on gls.chapter_id = c.id
                 join organizations o on c.organization_id = o.id
        where gls.lesson_date between '2021-09-01' and '2024-08-31'
        group by full_mlid, s.id, g.id
    ),
    -- Add lesson summaries and average marks
    student_group_lesson_summaries as (
        select sgs.*, slu.average_mark as lesson_average_mark, slu.lesson_id as lesson_id, slu.lesson_date as lesson_date, slu.subject_id
        from student_lesson_summaries slu
                 join student_group_summaries sgs on slu.student_id = sgs.student_id and slu.group_id = sgs.group_id
    )

-- Add grades for each skill
select sgls.full_mlid, sgls.student_id, sgls.dob, sgls.gender, sgls.country_of_nationality, sgls.group_id, sgls.group_name,
       sgls.lesson_date, sgls.lesson_average_mark, sgls.first_group_lesson, sgls.last_group_lesson, sgls.number_of_lessons_for_group,
       coalesce(jsonb_object_agg(sk.skill_name, mark) , '{}'::jsonb) AS skill_marks
from student_group_lesson_summaries sgls
         join assignments a on a.subject_id = sgls.subject_id
         left join skills sk on sk.id = a.skill_id
         left join grades gr on gr.student_id = sgls.student_id and gr.lesson_id = sgls.lesson_id and gr.skill_id = sk.id and gr.deleted_at is null
where sk.id in (1,2,3,4,5,6,7)
group by full_mlid, sgls.student_id, dob, gender, country_of_nationality, group_id, group_name, lesson_date, lesson_average_mark, first_group_lesson,
         last_group_lesson, number_of_lessons_for_group


