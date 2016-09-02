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

ActiveRecord::Schema.define(version: 20160901213654) do

  create_table "groups", force: :cascade do |t|
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.string   "group_name", default: "", null: false
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
    t.index ["group_id"], name: "index_students_on_group_id"
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
    t.index ["email"], name: "index_users_on_email", unique: true
  end

end
