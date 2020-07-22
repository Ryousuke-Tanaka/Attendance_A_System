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

ActiveRecord::Schema.define(version: 20200702131026) do

  create_table "applies", force: :cascade do |t|
    t.date "one_month"
    t.integer "one_month_request_status", default: 0, null: false
    t.integer "one_month_boss"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "change", default: false
    t.index ["user_id"], name: "index_applies_on_user_id"
  end

  create_table "attendances", force: :cascade do |t|
    t.date "worked_on"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.datetime "after_started_at"
    t.datetime "after_finished_at"
    t.string "note"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "spread_day", default: false
    t.datetime "estimated_finished_time"
    t.string "job_description"
    t.integer "boss"
    t.integer "overtime_request_status", default: 0, null: false
    t.integer "edit_attendance_request_status", default: 0, null: false
    t.boolean "change", default: false
    t.index ["user_id"], name: "index_attendances_on_user_id"
  end

  create_table "bases", force: :cascade do |t|
    t.integer "base_id"
    t.string "base_name"
    t.string "attendance_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["base_id"], name: "index_bases_on_base_id", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "password_digest"
    t.string "remember_digest"
    t.boolean "admin", default: false
    t.string "affiliation", default: "未所属"
    t.datetime "basic_time", default: "2020-07-21 23:00:00"
    t.datetime "work_time", default: "2020-07-21 22:30:00"
    t.datetime "designated_work_start_time", default: "2020-07-22 00:00:00"
    t.datetime "designated_work_end_time", default: "2020-07-22 09:00:00"
    t.boolean "superior", default: false
    t.integer "employee_number"
    t.string "uid"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["employee_number"], name: "index_users_on_employee_number", unique: true
    t.index ["uid"], name: "index_users_on_uid", unique: true
  end

end
