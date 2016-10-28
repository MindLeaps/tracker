# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20161025175655) do

  create_table "assignments", force: :cascade do |t|
    t.integer  "skill_id",   null: false
    t.integer  "subject_id", null: false
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["skill_id"], name: "index_assignments_on_skill_id"
    t.index ["subject_id"], name: "index_assignments_on_subject_id"
  end

  create_table "authentication_tokens", force: :cascade do |t|
    t.string   "body"
    t.integer  "user_id"
    t.datetime "last_used_at"
    t.string   "ip_address"
    t.string   "user_agent"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.index ["user_id"], name: "index_authentication_tokens_on_user_id"
  end

  create_table "chapters", force: :cascade do |t|
    t.string   "chapter_name",    null: false
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.integer  "organization_id"
    t.datetime "deleted_at"
    t.index ["organization_id"], name: "index_chapters_on_organization_id"
  end

  create_table "grade_descriptors", force: :cascade do |t|
    t.integer  "mark",              null: false
    t.string   "grade_description"
    t.integer  "skill_id",          null: false
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.datetime "deleted_at"
    t.index ["mark", "skill_id"], name: "index_grade_descriptors_on_mark_and_skill_id", unique: true
    t.index ["skill_id"], name: "index_grade_descriptors_on_skill_id"
  end

  create_table "grades", force: :cascade do |t|
    t.integer  "student_id",          null: false
    t.integer  "lesson_id",           null: false
    t.integer  "grade_descriptor_id", null: false
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.datetime "deleted_at"
    t.index ["grade_descriptor_id"], name: "index_grades_on_grade_descriptor_id"
    t.index ["lesson_id"], name: "index_grades_on_lesson_id"
    t.index ["student_id"], name: "index_grades_on_student_id"
  end

  create_table "groups", force: :cascade do |t|
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.string   "group_name", default: "", null: false
    t.integer  "chapter_id"
    t.datetime "deleted_at"
    t.index ["chapter_id"], name: "index_groups_on_chapter_id"
  end

  create_table "lessons", force: :cascade do |t|
    t.integer  "group_id",   null: false
    t.date     "date",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "subject_id", null: false
    t.datetime "deleted_at"
    t.index ["group_id"], name: "index_lessons_on_group_id"
    t.index ["subject_id"], name: "index_lessons_on_subject_id"
  end

  create_table "organizations", force: :cascade do |t|
    t.string   "organization_name",                                                                                         null: false
    t.datetime "created_at",                                                                                                null: false
    t.datetime "updated_at",                                                                                                null: false
    t.string   "image",             default: "https://placeholdit.imgix.net/~text?txtsize=23&txt=200%C3%97200&w=200&h=200"
    t.datetime "deleted_at"
  end

  create_table "roles", force: :cascade do |t|
    t.string   "name"
    t.string   "resource_type"
    t.integer  "resource_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id"
    t.index ["name"], name: "index_roles_on_name"
  end

  create_table "skills", force: :cascade do |t|
    t.string   "skill_name",        null: false
    t.integer  "organization_id",   null: false
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.text     "skill_description"
    t.datetime "deleted_at"
    t.index ["organization_id"], name: "index_skills_on_organization_id"
  end

  create_table "students", force: :cascade do |t|
    t.string   "first_name",                            null: false
    t.string   "last_name",                             null: false
    t.date     "dob",                                   null: false
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.boolean  "estimated_dob",          default: true, null: false
    t.integer  "group_id"
    t.integer  "gender",                 default: 0,    null: false
    t.string   "quartier"
    t.text     "health_insurance"
    t.text     "health_issues"
    t.boolean  "hiv_tested"
    t.string   "name_of_school"
    t.string   "school_level_completed"
    t.integer  "year_of_dropout"
    t.string   "reason_for_leaving"
    t.text     "notes"
    t.string   "guardian_name"
    t.string   "guardian_occupation"
    t.string   "guardian_contact"
    t.text     "family_members"
    t.integer  "organization_id",                       null: false
    t.string   "mlid",                                  null: false
    t.datetime "deleted_at"
    t.index ["group_id"], name: "index_students_on_group_id"
    t.index ["organization_id"], name: "index_students_on_organization_id"
  end

  create_table "subjects", force: :cascade do |t|
    t.string   "subject_name",    null: false
    t.integer  "organization_id", null: false
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.datetime "deleted_at"
    t.index ["organization_id"], name: "index_subjects_on_organization_id"
  end

  create_table "users", force: :cascade do |t|
    t.string   "uid"
    t.string   "name"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.string   "email",              default: "", null: false
    t.integer  "sign_in_count",      default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "provider"
    t.string   "image"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  create_table "users_roles", id: false, force: :cascade do |t|
    t.integer "user_id"
    t.integer "role_id"
    t.index ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id"
  end

end
