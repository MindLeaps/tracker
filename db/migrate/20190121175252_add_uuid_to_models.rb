# frozen_string_literal: true

class AddUuidToModels < ActiveRecord::Migration[5.2]
  # rubocop:disable Metrics/MethodLength
  def up
    add_column :organizations, :uid, :uuid, null: false, default: 'uuid_generate_v4()', index: { unique: true }
    add_column :chapters, :uid, :uuid, null: false, default: 'uuid_generate_v4()', index: { unique: true }
    add_column :groups, :uid, :uuid, null: false, default: 'uuid_generate_v4()', index: { unique: true }
    add_column :students, :uid, :uuid, null: false, default: 'uuid_generate_v4()', index: { unique: true }
    add_column :subjects, :uid, :uuid, null: false, default: 'uuid_generate_v4()', index: { unique: true }
    add_column :skills, :uid, :uuid, null: false, default: 'uuid_generate_v4()', index: { unique: true }
    add_column :assignments, :uid, :uuid, null: false, default: 'uuid_generate_v4()', index: { unique: true }
    add_column :grade_descriptors, :uid, :uuid, null: false, default: 'uuid_generate_v4()', index: { unique: true }
    add_column :lessons, :uid, :uuid, null: false, default: 'uuid_generate_v4()', index: { unique: true }
    add_column :grades, :uid, :uuid, null: false, default: 'uuid_generate_v4()', index: { unique: true }

    execute <<~SQL
      ALTER TABLE organizations ADD CONSTRAINT organization_uuid_unique UNIQUE(uid);
      ALTER TABLE chapters ADD CONSTRAINT chapter_uuid_unique UNIQUE(uid);
      ALTER TABLE groups ADD CONSTRAINT group_uuid_unique UNIQUE(uid);
      ALTER TABLE students ADD CONSTRAINT student_uuid_unique UNIQUE(uid);
      ALTER TABLE subjects ADD CONSTRAINT subject_uuid_unique UNIQUE(uid);
      ALTER TABLE skills ADD CONSTRAINT skill_uuid_unique UNIQUE(uid);
      ALTER TABLE assignments ADD CONSTRAINT assignment_uuid_unique UNIQUE(uid);
      ALTER TABLE grade_descriptors ADD CONSTRAINT grade_descriptor_uuid_unique UNIQUE(uid);
      ALTER TABLE lessons ADD CONSTRAINT lesson_uuid_unique UNIQUE(uid);
      ALTER TABLE grades ADD CONSTRAINT grade_uuid_unique UNIQUE(uid);
    SQL
  end

  def down
    remove_column :organizations, :uid
    remove_column :chapters, :uid
    remove_column :groups, :uid
    remove_column :students, :uid
    remove_column :subjects, :uid
    remove_column :skills, :uid
    remove_column :assignments, :uid
    remove_column :grade_descriptors, :uid
    remove_column :lessons, :uid
    remove_column :grades, :uid

    execute <<~SQL
      ALTER TABLE organizations DROP CONSTRAINT organization_uuid_unique;
      ALTER TABLE chapters DROP CONSTRAINT chapter_uuid_unique;
      ALTER TABLE groups DROP CONSTRAINT group_uuid_unique;
      ALTER TABLE students DROP CONSTRAINT student_uuid_unique;
      ALTER TABLE subjects DROP CONSTRAINT subject_uuid_unique;
      ALTER TABLE skills DROP CONSTRAINT skill_uuid_unique;
      ALTER TABLE assignments DROP CONSTRAINT assignment_uuid_unique;
      ALTER TABLE grade_descriptors DROP CONSTRAINT grade_descriptor_uuid_unique;
      ALTER TABLE lessons DROP CONSTRAINT lesson_uuid_unique;
      ALTER TABLE grades DROP CONSTRAINT grade_uuid_unique;
    SQL
  end
  # rubocop:enable Metrics/MethodLength
end
