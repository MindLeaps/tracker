select su.id as id, su.subject_name, su.organization_id, sum(case when a.deleted_at is not null then 0 else 1 end) as skill_count, su.created_at, su.updated_at, su.deleted_at
from subjects su left join assignments a on su.id = a.subject_id left join skills sk on sk.id = a.skill_id
where sk.deleted_at is null
group by su.id