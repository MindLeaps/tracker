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

ActiveRecord::Schema.define(version: 20160915231926) do

  create_table "chapters", force: :cascade do |t|
    t.string   "chapter_name",    null: false
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.integer  "organization_id"
    t.index ["organization_id"], name: "index_chapters_on_organization_id"
  end

  create_table "groups", force: :cascade do |t|
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.string   "group_name", default: "", null: false
    t.integer  "chapter_id"
    t.index ["chapter_id"], name: "index_groups_on_chapter_id"
  end

  create_table "lessons", force: :cascade do |t|
    t.integer  "group_id",   null: false
    t.date     "date",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id"], name: "index_lessons_on_group_id"
  end

  create_table "organizations", force: :cascade do |t|
    t.string   "organization_name",                                                                                         null: false
    t.datetime "created_at",                                                                                                null: false
    t.datetime "updated_at",                                                                                                null: false
    t.string   "image",             default: "https://placeholdit.imgix.net/~text?txtsize=23&txt=200%C3%97200&w=200&h=200"
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
    t.index ["group_id"], name: "index_students_on_group_id"
    t.index ["organization_id"], name: "index_students_on_organization_id"
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
