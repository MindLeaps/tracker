WITH local AS (
    SELECT u.*, r.name as local_role, r.resource_id as organization_id FROM users u
        JOIN users_roles ur ON u.id = ur.user_id
        JOIN roles r ON r.id = ur.role_id
    WHERE resource_type = 'Organization'
),
global AS (
    SELECT u.id, r.name as global_role FROM users u
        JOIN users_roles ur ON u.id = ur.user_id
        JOIN roles r ON r.id = ur.role_id
    WHERE resource_type IS NULL
)
SELECT local.*, global.global_role from local left join global on local.id = global.id
