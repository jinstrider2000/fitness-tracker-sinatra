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

ActiveRecord::Schema.define(version: 20170513011748) do

  create_table "achievements", force: :cascade do |t|
    t.string   "activity_type"
    t.integer  "activity_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.index ["activity_type", "activity_id"], name: "index_achievements_on_activity_type_and_activity_id"
  end

  create_table "exercises", force: :cascade do |t|
    t.string   "name"
    t.integer  "calories_burned"
    t.integer  "user_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  create_table "foods", force: :cascade do |t|
    t.string   "name"
    t.integer  "calories"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "username"
    t.string   "name"
    t.string   "password_digest"
    t.integer  "daily_calorie_goal"
    t.string   "slug"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

end
