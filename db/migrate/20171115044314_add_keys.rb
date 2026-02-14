class AddKeys < ActiveRecord::Migration[5.1]
  def change
    add_foreign_key 'assignments', 'skills', name: 'assignments_skill_id_fk'
    add_foreign_key 'assignments', 'subjects', name: 'assignments_subject_id_fk'
    add_foreign_key 'chapters', 'organizations', name: 'chapters_organization_id_fk'
    add_foreign_key 'grade_descriptors', 'skills', name: 'grade_descriptors_skill_id_fk'
    add_foreign_key 'grades', 'grade_descriptors', name: 'grades_grade_descriptor_id_fk'
    add_foreign_key 'grades', 'lessons', name: 'grades_lesson_id_fk'
    add_foreign_key 'grades', 'students', name: 'grades_student_id_fk'
    add_foreign_key 'groups', 'chapters', name: 'groups_chapter_id_fk'
    add_foreign_key 'lessons', 'groups', name: 'lessons_group_id_fk'
    add_foreign_key 'lessons', 'subjects', name: 'lessons_subject_id_fk'
    add_foreign_key 'skills', 'organizations', name: 'skills_organization_id_fk'
    add_foreign_key 'student_images', 'students', name: 'student_images_student_id_fk'
    add_foreign_key 'students', 'groups', name: 'students_group_id_fk'
    add_foreign_key 'students', 'organizations', name: 'students_organization_id_fk'
    add_foreign_key 'subjects', 'organizations', name: 'subjects_organization_id_fk'
    add_foreign_key 'users_roles', 'roles', name: 'users_roles_role_id_fk'
    add_foreign_key 'users_roles', 'users', name: 'users_roles_user_id_fk'
  end
end
