# frozen_string_literal: true

class AddUidsRelations < ActiveRecord::Migration[5.2]
  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/AbcSize
  def change
    add_column :chapters, :organization_uid, :uuid
    add_foreign_key :chapters, :organizations, column: :organization_uid, primary_key: :uid, name: 'chapters_organization_uid_fk'

    add_column :groups, :chapter_uid, :uuid
    add_foreign_key :groups, :chapters, column: :chapter_uid, primary_key: :uid, name: 'groups_chapter_uid_fk'

    add_column :students, :group_uid, :uuid
    add_foreign_key :students, :groups, column: :group_uid, primary_key: :uid, name: 'students_group_uid_fk'

    add_column :subjects, :organization_uid, :uuid
    add_foreign_key :subjects, :organizations, column: :organization_uid, primary_key: :uid, name: 'subjects_organization_uid_fk'

    add_column :skills, :organization_uid, :uuid
    add_foreign_key :skills, :organizations, column: :organization_uid, primary_key: :uid, name: 'skills_organization_uid_fk'

    add_column :grade_descriptors, :skill_uid, :uuid
    add_foreign_key :grade_descriptors, :skills, column: :skill_uid, primary_key: :uid, name: 'grade_descriptors_skill_uid_fk'

    add_column :lessons, :group_uid, :uuid
    add_foreign_key :lessons, :groups, column: :group_uid, primary_key: :uid, name: 'lessons_group_uid_fk'

    add_column :lessons, :subject_uid, :uuid
    add_foreign_key :lessons, :subjects, column: :subject_uid, primary_key: :uid, name: 'lessons_subject_uid_fk'

    add_column :grades, :student_uid, :uuid
    add_foreign_key :grades, :students, column: :student_uid, primary_key: :uid, name: 'grades_student_uid_fk'

    add_column :grades, :lesson_uid, :uuid
    add_foreign_key :grades, :lessons, column: :lesson_uid, primary_key: :uid, name: 'grades_lesson_uid_fk'

    add_column :grades, :grade_descriptor_uid, :uuid
    add_foreign_key :grades, :grade_descriptors, column: :grade_descriptor_uid, primary_key: :uid, name: 'grades_grade_descriptor_uid_fk'

    Chapter.includes(:organization).all.each do |c|
      c.organization_uid = c.organization.uid
      c.save!
    end

    Group.includes(:chapter).all.each do |g|
      g.chapter_uid = g.chapter.uid
      g.save!
    end

    Student.includes(:group).all.each do |s|
      s.group_uid = s.group.uid
      s.save!
    end

    Subject.includes(:organization).all.each do |s|
      s.organization_uid = s.organization.uid
      s.save!
    end

    Skill.includes(:organization).all.each do |s|
      s.organization_uid = s.organization.uid
      s.save!
    end

    GradeDescriptor.includes(:skill).all.each do |gd|
      gd.skill_uid = gd.skill.uid
      gd.save!
    end

    Lesson.includes(%i[group subject]).all.each do |l|
      l.group_uid = l.group.uid
      l.subject_uid = l.subject.uid
      l.save!
    end

    Grade.includes(%i[student lesson grade_descriptor]).all.each do |g|
      g.student_uid = g.student.uid
      g.lesson_uid = g.lesson.uid
      g.grade_descriptor_uid = g.grade_descriptor.uid
      g.save!
    end

    change_column_null :chapters, :organization_uid, false
    change_column_null :groups, :chapter_uid, false
    change_column_null :students, :group_uid, false
    change_column_null :subjects, :organization_uid, false
    change_column_null :skills, :organization_uid, false
    change_column_null :grade_descriptors, :skill_uid, false
    change_column_null :lessons, :group_uid, false
    change_column_null :lessons, :subject_uid, false
    change_column_null :grades, :student_uid, false
    change_column_null :grades, :lesson_uid, false
    change_column_null :grades, :grade_descriptor_uid, false
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength
end
