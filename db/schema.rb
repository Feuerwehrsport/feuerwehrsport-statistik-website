# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20150927070536) do

  create_table "competitions", force: :cascade do |t|
    t.string   "name",          limit: 255, default: "", null: false
    t.integer  "place_id",      limit: 4,                null: false
    t.integer  "event_id",      limit: 4,                null: false
    t.integer  "score_type_id", limit: 4
    t.date     "date",                                   null: false
    t.datetime "published_at"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
  end

  add_index "competitions", ["event_id"], name: "index_competitions_on_event_id", using: :btree
  add_index "competitions", ["place_id"], name: "index_competitions_on_place_id", using: :btree
  add_index "competitions", ["score_type_id"], name: "index_competitions_on_score_type_id", using: :btree

  create_table "events", force: :cascade do |t|
    t.string   "name",       limit: 255, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "group_score_categories", force: :cascade do |t|
    t.integer  "group_score_type_id", limit: 4,   null: false
    t.integer  "competition_id",      limit: 4,   null: false
    t.string   "name",                limit: 255, null: false
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
  end

  add_index "group_score_categories", ["competition_id"], name: "index_group_score_categories_on_competition_id", using: :btree
  add_index "group_score_categories", ["group_score_type_id"], name: "index_group_score_categories_on_group_score_type_id", using: :btree

  create_table "group_score_types", force: :cascade do |t|
    t.string   "discipline", limit: 255,                 null: false
    t.string   "name",       limit: 255,                 null: false
    t.boolean  "regular",                default: false, null: false
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
  end

  create_table "group_scores", force: :cascade do |t|
    t.integer  "team_id",                 limit: 4,               null: false
    t.integer  "team_number",             limit: 4,   default: 0, null: false
    t.integer  "gender",                  limit: 4,               null: false
    t.integer  "time",                    limit: 4,               null: false
    t.integer  "group_score_category_id", limit: 4,               null: false
    t.string   "run",                     limit: 255,             null: false
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
  end

  add_index "group_scores", ["group_score_category_id"], name: "index_group_scores_on_group_score_category_id", using: :btree
  add_index "group_scores", ["team_id"], name: "index_group_scores_on_team_id", using: :btree

  create_table "nations", force: :cascade do |t|
    t.string   "name",       limit: 255, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "people", force: :cascade do |t|
    t.string   "last_name",  limit: 255, null: false
    t.string   "first_name", limit: 255, null: false
    t.integer  "gender",     limit: 4,   null: false
    t.integer  "nation_id",  limit: 4,   null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "people", ["gender"], name: "index_people_on_gender", using: :btree
  add_index "people", ["nation_id"], name: "index_people_on_nation_id", using: :btree

  create_table "person_participations", force: :cascade do |t|
    t.integer  "person_id",      limit: 4, null: false
    t.integer  "group_score_id", limit: 4, null: false
    t.integer  "position",       limit: 4, null: false
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "person_participations", ["group_score_id"], name: "index_person_participations_on_group_score_id", using: :btree
  add_index "person_participations", ["person_id"], name: "index_person_participations_on_person_id", using: :btree

  create_table "places", force: :cascade do |t|
    t.string   "name",       limit: 255,                           null: false
    t.decimal  "latitude",               precision: 15, scale: 10
    t.decimal  "longitude",              precision: 15, scale: 10
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at",                                       null: false
  end

  create_table "score_types", force: :cascade do |t|
    t.integer  "people",     limit: 4, null: false
    t.integer  "run",        limit: 4, null: false
    t.integer  "score",      limit: 4, null: false
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  create_table "scores", force: :cascade do |t|
    t.integer  "person_id",      limit: 4,               null: false
    t.string   "discipline",     limit: 255,             null: false
    t.integer  "competition_id", limit: 4,               null: false
    t.integer  "time",           limit: 4,               null: false
    t.integer  "team_id",        limit: 4
    t.integer  "team_number",    limit: 4,   default: 0, null: false
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
  end

  add_index "scores", ["competition_id"], name: "index_scores_on_competition_id", using: :btree
  add_index "scores", ["person_id"], name: "index_scores_on_person_id", using: :btree
  add_index "scores", ["team_id"], name: "index_scores_on_team_id", using: :btree

  create_table "teams", force: :cascade do |t|
    t.string   "name",       limit: 255,                           null: false
    t.string   "shortcut",   limit: 255,                           null: false
    t.integer  "status",     limit: 4,                             null: false
    t.decimal  "latitude",               precision: 15, scale: 10
    t.decimal  "longitude",              precision: 15, scale: 10
    t.string   "image",      limit: 255
    t.string   "state",      limit: 255,                           null: false
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at",                                       null: false
  end

  add_foreign_key "competitions", "events"
  add_foreign_key "competitions", "places"
  add_foreign_key "competitions", "score_types"
  add_foreign_key "group_score_categories", "competitions"
  add_foreign_key "group_score_categories", "group_score_types"
  add_foreign_key "group_scores", "group_score_categories"
  add_foreign_key "group_scores", "teams"
  add_foreign_key "people", "nations"
  add_foreign_key "person_participations", "group_scores"
  add_foreign_key "person_participations", "people"
  add_foreign_key "scores", "competitions"
  add_foreign_key "scores", "people"
  add_foreign_key "scores", "teams"
end
