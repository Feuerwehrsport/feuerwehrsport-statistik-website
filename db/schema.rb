# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2023_03_21_121606) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "fuzzystrmatch"
  enable_extension "plpgsql"

  create_table "active_record_views", primary_key: "name", id: :text, force: :cascade do |t|
    t.text     "class_name",   :null=>false, :index=>{:name=>"active_record_views_class_name_key", :unique=>true}
    t.text     "checksum",     :null=>false
    t.json     "options",      :default=>{}, :null=>false
    t.datetime "refreshed_at", :precision=>nil
  end

  create_table "admin_users", id: :serial, force: :cascade do |t|
    t.string   "role",       :limit=>200, :default=>"user", :null=>false
    t.datetime "created_at", :precision=>nil, :null=>false
    t.datetime "updated_at", :precision=>nil, :null=>false
    t.integer  "login_id",   :null=>false, :index=>{:name=>"index_admin_users_on_login_id"}
  end

  create_table "api_users", id: :serial, force: :cascade do |t|
    t.string   "name",            :limit=>200, :null=>false
    t.string   "email_address",   :limit=>200
    t.string   "ip_address_hash", :limit=>200, :null=>false
    t.string   "user_agent_hash", :limit=>200, :null=>false
    t.string   "user_agent_meta", :limit=>1000
    t.datetime "created_at",      :precision=>nil, :null=>false
    t.datetime "updated_at",      :precision=>nil, :null=>false
  end

  create_table "appointments", id: :serial, force: :cascade do |t|
    t.date     "dated_at",     :null=>false
    t.string   "name",         :limit=>200, :null=>false
    t.text     "description",  :null=>false
    t.integer  "event_id",     :index=>{:name=>"index_appointments_on_event_id"}
    t.string   "disciplines",  :limit=>200, :default=>"", :null=>false
    t.datetime "created_at",   :precision=>nil, :null=>false
    t.datetime "updated_at",   :precision=>nil, :null=>false
    t.integer  "creator_id"
    t.string   "creator_type"
    t.string   "place",        :limit=>200
  end

  create_table "bla_badges", id: :serial, force: :cascade do |t|
    t.integer  "person_id",   :null=>false, :index=>{:name=>"index_bla_badges_on_person_id", :unique=>true}
    t.string   "status",      :limit=>200, :null=>false
    t.integer  "year",        :null=>false
    t.integer  "hl_time"
    t.integer  "hl_score_id", :index=>{:name=>"index_bla_badges_on_hl_score_id"}
    t.integer  "hb_time",     :null=>false
    t.integer  "hb_score_id", :index=>{:name=>"index_bla_badges_on_hb_score_id"}
    t.datetime "created_at",  :precision=>nil, :null=>false
    t.datetime "updated_at",  :precision=>nil, :null=>false
  end

  create_table "change_logs", id: :serial, force: :cascade do |t|
    t.integer  "admin_user_id", :index=>{:name=>"index_change_logs_on_admin_user_id"}
    t.integer  "api_user_id",   :index=>{:name=>"index_change_logs_on_api_user_id"}
    t.string   "model_class",   :null=>false
    t.json     "content",       :null=>false
    t.datetime "created_at",    :precision=>nil, :null=>false
    t.datetime "updated_at",    :precision=>nil, :null=>false
    t.string   "action",        :null=>false
  end

  create_table "change_requests", id: :serial, force: :cascade do |t|
    t.integer  "api_user_id",   :index=>{:name=>"index_change_requests_on_api_user_id"}
    t.integer  "admin_user_id", :index=>{:name=>"index_change_requests_on_admin_user_id"}
    t.json     "content",       :null=>false
    t.datetime "done_at",       :precision=>nil
    t.datetime "created_at",    :precision=>nil, :null=>false
    t.datetime "updated_at",    :precision=>nil, :null=>false
    t.json     "files_data",    :default=>{}
  end

  create_table "competition_files", id: :serial, force: :cascade do |t|
    t.integer  "competition_id", :null=>false, :index=>{:name=>"index_competition_files_on_competition_id"}
    t.string   "file",           :null=>false
    t.string   "keys_string",    :limit=>200
    t.datetime "created_at",     :precision=>nil, :null=>false
    t.datetime "updated_at",     :precision=>nil, :null=>false
  end

  create_table "competitions", id: :serial, force: :cascade do |t|
    t.string   "name",                    :limit=>200, :default=>"", :null=>false
    t.integer  "place_id",                :null=>false, :index=>{:name=>"index_competitions_on_place_id"}
    t.integer  "event_id",                :null=>false, :index=>{:name=>"index_competitions_on_event_id"}
    t.integer  "score_type_id",           :index=>{:name=>"index_competitions_on_score_type_id"}
    t.date     "date",                    :null=>false
    t.datetime "published_at",            :precision=>nil
    t.datetime "created_at",              :precision=>nil, :null=>false
    t.datetime "updated_at",              :precision=>nil, :null=>false
    t.text     "hint_content",            :default=>"", :null=>false
    t.integer  "hl_female",               :default=>0, :null=>false
    t.integer  "hl_male",                 :default=>0, :null=>false
    t.integer  "hb_female",               :default=>0, :null=>false
    t.integer  "hb_male",                 :default=>0, :null=>false
    t.integer  "gs",                      :default=>0, :null=>false
    t.integer  "fs_female",               :default=>0, :null=>false
    t.integer  "fs_male",                 :default=>0, :null=>false
    t.integer  "la_female",               :default=>0, :null=>false
    t.integer  "la_male",                 :default=>0, :null=>false
    t.integer  "teams_count",             :default=>0, :null=>false
    t.integer  "people_count",            :default=>0, :null=>false
    t.string   "long_name",               :limit=>200
    t.boolean  "hb_male_for_bla_badge",   :default=>false, :null=>false
    t.boolean  "hl_male_for_bla_badge",   :default=>false, :null=>false
    t.boolean  "hb_female_for_bla_badge", :default=>false, :null=>false
    t.boolean  "hl_female_for_bla_badge", :default=>false, :null=>false
  end

  create_table "delayed_jobs", id: :serial, force: :cascade do |t|
    t.integer  "priority",   :default=>0, :null=>false, :index=>{:name=>"delayed_jobs_priority", :with=>["run_at"]}
    t.integer  "attempts",   :default=>0, :null=>false
    t.text     "handler",    :null=>false
    t.text     "last_error"
    t.datetime "run_at",     :precision=>nil
    t.datetime "locked_at",  :precision=>nil
    t.datetime "failed_at",  :precision=>nil
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at", :precision=>nil
    t.datetime "updated_at", :precision=>nil
  end

  create_table "entity_merges", id: :serial, force: :cascade do |t|
    t.integer  "source_id",   :null=>false
    t.string   "source_type", :null=>false, :index=>{:name=>"index_entity_merges_on_source_type_and_source_id", :with=>["source_id"]}
    t.integer  "target_id",   :null=>false
    t.string   "target_type", :null=>false, :index=>{:name=>"index_entity_merges_on_target_type_and_target_id", :with=>["target_id"]}
    t.datetime "created_at",  :precision=>nil, :null=>false
    t.datetime "updated_at",  :precision=>nil, :null=>false
  end

  create_table "events", id: :serial, force: :cascade do |t|
    t.string   "name",       :limit=>200, :null=>false
    t.datetime "created_at", :precision=>nil, :null=>false
    t.datetime "updated_at", :precision=>nil, :null=>false
  end

  create_table "federal_states", id: :serial, force: :cascade do |t|
    t.string   "name",       :limit=>200, :null=>false
    t.string   "shortcut",   :limit=>10, :null=>false
    t.datetime "created_at", :precision=>nil, :null=>false
    t.datetime "updated_at", :precision=>nil, :null=>false
  end

  create_table "group_score_categories", id: :serial, force: :cascade do |t|
    t.integer  "group_score_type_id", :null=>false, :index=>{:name=>"index_group_score_categories_on_group_score_type_id"}
    t.integer  "competition_id",      :null=>false, :index=>{:name=>"index_group_score_categories_on_competition_id"}
    t.string   "name",                :limit=>200, :null=>false
    t.datetime "created_at",          :precision=>nil, :null=>false
    t.datetime "updated_at",          :precision=>nil, :null=>false
  end

  create_table "group_score_types", id: :serial, force: :cascade do |t|
    t.string   "discipline", :null=>false
    t.string   "name",       :limit=>200, :null=>false
    t.boolean  "regular",    :default=>false, :null=>false
    t.datetime "created_at", :precision=>nil, :null=>false
    t.datetime "updated_at", :precision=>nil, :null=>false
  end

  create_table "group_scores", id: :serial, force: :cascade do |t|
    t.integer  "team_id",                 :null=>false, :index=>{:name=>"index_group_scores_on_team_id"}
    t.integer  "team_number",             :default=>0, :null=>false
    t.integer  "gender",                  :null=>false
    t.integer  "time",                    :null=>false
    t.integer  "group_score_category_id", :null=>false, :index=>{:name=>"index_group_scores_on_group_score_category_id"}
    t.string   "run",                     :limit=>1
    t.datetime "created_at",              :precision=>nil, :null=>false
    t.datetime "updated_at",              :precision=>nil, :null=>false
  end

  create_table "import_request_files", id: :serial, force: :cascade do |t|
    t.integer  "import_request_id", :null=>false, :index=>{:name=>"index_import_request_files_on_import_request_id"}
    t.string   "file",              :null=>false
    t.datetime "created_at",        :precision=>nil, :null=>false
    t.datetime "updated_at",        :precision=>nil, :null=>false
    t.boolean  "transfered",        :default=>false, :null=>false
  end

  create_table "import_requests", id: :serial, force: :cascade do |t|
    t.string   "file"
    t.string   "url"
    t.date     "date"
    t.integer  "place_id",      :index=>{:name=>"index_import_requests_on_place_id"}
    t.integer  "event_id",      :index=>{:name=>"index_import_requests_on_event_id"}
    t.text     "description"
    t.integer  "admin_user_id", :index=>{:name=>"index_import_requests_on_admin_user_id"}
    t.integer  "edit_user_id",  :index=>{:name=>"index_import_requests_on_edit_user_id"}
    t.datetime "edited_at",     :precision=>nil
    t.datetime "finished_at",   :precision=>nil
    t.datetime "created_at",    :precision=>nil, :null=>false
    t.datetime "updated_at",    :precision=>nil, :null=>false
    t.json     "import_data"
  end

  create_table "links", id: :serial, force: :cascade do |t|
    t.string   "label",         :null=>false
    t.integer  "linkable_id",   :null=>false
    t.string   "linkable_type", :null=>false
    t.text     "url",           :null=>false
    t.datetime "created_at",    :precision=>nil, :null=>false
    t.datetime "updated_at",    :precision=>nil, :null=>false
  end

  create_table "m3_assets", id: :serial, force: :cascade do |t|
    t.string   "file"
    t.string   "name",       :limit=>200
    t.boolean  "image",      :default=>false, :null=>false
    t.datetime "created_at", :precision=>nil, :null=>false
    t.datetime "updated_at", :precision=>nil, :null=>false
  end

  create_table "m3_logins", id: :serial, force: :cascade do |t|
    t.string   "name"
    t.string   "email_address",                      :null=>false
    t.string   "password_digest"
    t.datetime "verified_at",                        :precision=>nil
    t.string   "verify_token",                       :index=>{:name=>"index_m3_logins_on_verify_token", :unique=>true}
    t.datetime "created_at",                         :precision=>nil, :null=>false
    t.datetime "updated_at",                         :precision=>nil, :null=>false
    t.datetime "password_reset_requested_at",        :precision=>nil
    t.string   "password_reset_token",               :index=>{:name=>"index_m3_logins_on_password_reset_token", :unique=>true}
    t.datetime "expired_at",                         :precision=>nil
    t.string   "changed_email_address"
    t.string   "changed_email_address_token",        :null=>false, :index=>{:name=>"index_m3_logins_on_changed_email_address_token", :unique=>true}
    t.datetime "changed_email_address_requested_at", :precision=>nil
  end

  create_table "nations", id: :serial, force: :cascade do |t|
    t.string   "name",       :limit=>200, :null=>false
    t.string   "iso",        :limit=>10, :null=>false
    t.datetime "created_at", :precision=>nil, :null=>false
    t.datetime "updated_at", :precision=>nil, :null=>false
  end

  create_table "people", id: :serial, force: :cascade do |t|
    t.string   "last_name",              :limit=>200, :null=>false
    t.string   "first_name",             :limit=>200, :null=>false
    t.integer  "gender",                 :null=>false, :index=>{:name=>"index_people_on_gender"}
    t.integer  "nation_id",              :null=>false, :index=>{:name=>"index_people_on_nation_id"}
    t.datetime "created_at",             :precision=>nil, :null=>false
    t.datetime "updated_at",             :precision=>nil, :null=>false
    t.integer  "hb_count",               :default=>0, :null=>false
    t.integer  "hl_count",               :default=>0, :null=>false
    t.integer  "la_count",               :default=>0, :null=>false
    t.integer  "fs_count",               :default=>0, :null=>false
    t.integer  "gs_count",               :default=>0, :null=>false
    t.jsonb    "best_scores",            :default=>{}
    t.integer  "ignore_bla_untill_year"
  end

  create_table "person_participations", id: :serial, force: :cascade do |t|
    t.integer  "person_id",      :null=>false, :index=>{:name=>"index_person_participations_on_person_id"}
    t.integer  "group_score_id", :null=>false, :index=>{:name=>"index_person_participations_on_group_score_id"}
    t.integer  "position",       :null=>false
    t.datetime "created_at",     :precision=>nil, :null=>false
    t.datetime "updated_at",     :precision=>nil, :null=>false
  end

  create_table "person_spellings", id: :serial, force: :cascade do |t|
    t.integer  "person_id",  :null=>false, :index=>{:name=>"index_person_spellings_on_person_id"}
    t.string   "last_name",  :limit=>200, :null=>false
    t.string   "first_name", :limit=>200, :null=>false
    t.integer  "gender",     :null=>false
    t.boolean  "official",   :default=>false, :null=>false
    t.datetime "created_at", :precision=>nil, :null=>false
    t.datetime "updated_at", :precision=>nil, :null=>false
  end

  create_table "places", id: :serial, force: :cascade do |t|
    t.string   "name",       :limit=>200, :null=>false
    t.decimal  "latitude",   :precision=>15, :scale=>10
    t.decimal  "longitude",  :precision=>15, :scale=>10
    t.datetime "created_at", :precision=>nil, :null=>false
    t.datetime "updated_at", :precision=>nil, :null=>false
  end

  create_table "registrations_assessment_participations", id: :serial, force: :cascade do |t|
    t.string   "type",                    :null=>false
    t.integer  "assessment_id",           :null=>false
    t.integer  "team_id"
    t.integer  "person_id"
    t.integer  "assessment_type",         :default=>0, :null=>false
    t.integer  "single_competitor_order", :default=>0, :null=>false
    t.integer  "group_competitor_order",  :default=>0, :null=>false
    t.datetime "created_at",              :precision=>nil, :null=>false
    t.datetime "updated_at",              :precision=>nil, :null=>false
    t.integer  "competitor_order",        :default=>0, :null=>false
  end

  create_table "registrations_assessments", id: :serial, force: :cascade do |t|
    t.integer  "competition_id", :null=>false
    t.string   "discipline",     :null=>false
    t.string   "name",           :default=>"", :null=>false
    t.integer  "gender",         :null=>false
    t.datetime "created_at",     :precision=>nil, :null=>false
    t.datetime "updated_at",     :precision=>nil, :null=>false
    t.boolean  "show_only_name", :default=>false, :null=>false
  end

  create_table "registrations_competitions", id: :serial, force: :cascade do |t|
    t.string   "name",          :null=>false
    t.date     "date",          :null=>false
    t.string   "place",         :null=>false
    t.text     "description",   :default=>"", :null=>false
    t.datetime "open_at",       :precision=>nil
    t.datetime "close_at",      :precision=>nil
    t.integer  "admin_user_id", :null=>false
    t.string   "person_tags",   :default=>"", :null=>false
    t.string   "team_tags",     :default=>"", :null=>false
    t.datetime "created_at",    :precision=>nil, :null=>false
    t.datetime "updated_at",    :precision=>nil, :null=>false
    t.string   "slug",          :index=>{:name=>"index_registrations_competitions_on_slug", :unique=>true}
    t.boolean  "published",     :default=>false, :null=>false
    t.boolean  "group_score",   :default=>false, :null=>false
    t.text     "hint_to_hint"
  end

  create_table "registrations_people", id: :serial, force: :cascade do |t|
    t.integer  "competition_id",     :null=>false
    t.integer  "team_id"
    t.integer  "person_id"
    t.integer  "admin_user_id",      :null=>false
    t.string   "first_name",         :null=>false
    t.string   "last_name",          :null=>false
    t.integer  "gender",             :null=>false
    t.datetime "created_at",         :precision=>nil, :null=>false
    t.datetime "updated_at",         :precision=>nil, :null=>false
    t.integer  "registration_order", :default=>0, :null=>false
    t.string   "team_name"
  end

  create_table "registrations_teams", id: :serial, force: :cascade do |t|
    t.integer  "competition_id",           :null=>false
    t.integer  "team_id"
    t.string   "name",                     :null=>false
    t.string   "shortcut",                 :null=>false
    t.integer  "gender",                   :null=>false
    t.integer  "team_number",              :default=>1, :null=>false
    t.string   "team_leader",              :default=>"", :null=>false
    t.string   "street_with_house_number", :default=>"", :null=>false
    t.string   "postal_code",              :default=>"", :null=>false
    t.string   "locality",                 :default=>"", :null=>false
    t.string   "phone_number",             :default=>"", :null=>false
    t.string   "email_address",            :default=>"", :null=>false
    t.integer  "admin_user_id",            :null=>false
    t.datetime "created_at",               :precision=>nil, :null=>false
    t.datetime "updated_at",               :precision=>nil, :null=>false
    t.integer  "federal_state_id"
    t.text     "hint"
  end

  create_table "score_types", id: :serial, force: :cascade do |t|
    t.integer  "people",     :null=>false
    t.integer  "run",        :null=>false
    t.integer  "score",      :null=>false
    t.datetime "created_at", :precision=>nil, :null=>false
    t.datetime "updated_at", :precision=>nil, :null=>false
  end

  create_table "scores", id: :serial, force: :cascade do |t|
    t.integer  "person_id",      :null=>false, :index=>{:name=>"index_scores_on_person_id"}
    t.string   "discipline",     :null=>false
    t.integer  "competition_id", :null=>false, :index=>{:name=>"index_scores_on_competition_id"}
    t.integer  "time",           :null=>false
    t.integer  "team_id",        :index=>{:name=>"index_scores_on_team_id"}
    t.integer  "team_number",    :default=>0, :null=>false
    t.datetime "created_at",     :precision=>nil, :null=>false
    t.datetime "updated_at",     :precision=>nil, :null=>false
  end

  create_table "series_assessments", id: :serial, force: :cascade do |t|
    t.integer  "round_id",   :null=>false
    t.string   "discipline", :limit=>3, :null=>false
    t.string   "name",       :limit=>200, :default=>"", :null=>false
    t.string   "type",       :limit=>200, :null=>false
    t.integer  "gender",     :null=>false
    t.datetime "created_at", :precision=>nil, :null=>false
    t.datetime "updated_at", :precision=>nil, :null=>false
  end

  create_table "series_cups", id: :serial, force: :cascade do |t|
    t.integer  "round_id",       :null=>false
    t.integer  "competition_id", :null=>false
    t.datetime "created_at",     :precision=>nil, :null=>false
    t.datetime "updated_at",     :precision=>nil, :null=>false
  end

  create_table "series_kinds", force: :cascade do |t|
    t.string   "name",       :null=>false
    t.string   "slug",       :null=>false, :index=>{:name=>"index_series_kinds_on_slug", :unique=>true}
    t.datetime "created_at", :null=>false
    t.datetime "updated_at", :null=>false
  end

  create_table "series_participations", id: :serial, force: :cascade do |t|
    t.integer  "assessment_id", :null=>false
    t.integer  "cup_id",        :null=>false
    t.string   "type",          :null=>false
    t.integer  "team_id"
    t.integer  "team_number"
    t.integer  "person_id"
    t.integer  "time",          :null=>false
    t.integer  "points",        :default=>0, :null=>false
    t.integer  "rank",          :null=>false
    t.datetime "created_at",    :precision=>nil, :null=>false
    t.datetime "updated_at",    :precision=>nil, :null=>false
  end

  create_table "series_rounds", id: :serial, force: :cascade do |t|
    t.integer  "year",           :null=>false
    t.string   "aggregate_type", :null=>false
    t.datetime "created_at",     :precision=>nil, :null=>false
    t.datetime "updated_at",     :precision=>nil, :null=>false
    t.boolean  "official",       :default=>false, :null=>false
    t.integer  "full_cup_count", :default=>4, :null=>false
    t.bigint   "kind_id",        :index=>{:name=>"index_series_rounds_on_kind_id"}
  end

  create_table "tags", id: :serial, force: :cascade do |t|
    t.integer  "taggable_id",   :null=>false
    t.string   "taggable_type", :null=>false
    t.string   "name",          :null=>false
    t.datetime "created_at",    :precision=>nil, :null=>false
    t.datetime "updated_at",    :precision=>nil, :null=>false
  end

  create_table "team_spellings", id: :serial, force: :cascade do |t|
    t.integer  "team_id",    :null=>false, :index=>{:name=>"index_team_spellings_on_team_id"}
    t.string   "name",       :limit=>200, :null=>false
    t.string   "shortcut",   :limit=>200, :null=>false
    t.datetime "created_at", :precision=>nil, :null=>false
    t.datetime "updated_at", :precision=>nil, :null=>false
  end

  create_table "teams", id: :serial, force: :cascade do |t|
    t.string   "name",               :limit=>200, :null=>false
    t.string   "shortcut",           :limit=>200, :null=>false
    t.integer  "status",             :null=>false
    t.decimal  "latitude",           :precision=>15, :scale=>10
    t.decimal  "longitude",          :precision=>15, :scale=>10
    t.string   "image"
    t.string   "state",              :limit=>200, :default=>"", :null=>false
    t.datetime "created_at",         :precision=>nil, :null=>false
    t.datetime "updated_at",         :precision=>nil, :null=>false
    t.datetime "checked_at",         :precision=>nil
    t.integer  "members_count",      :default=>0, :null=>false
    t.integer  "competitions_count", :default=>0, :null=>false
  end

  add_foreign_key "admin_users", "m3_logins", column: "login_id"
  add_foreign_key "appointments", "events"
  add_foreign_key "bla_badges", "people"
  add_foreign_key "bla_badges", "scores", column: "hb_score_id"
  add_foreign_key "bla_badges", "scores", column: "hl_score_id"
  add_foreign_key "change_logs", "admin_users"
  add_foreign_key "change_logs", "api_users"
  add_foreign_key "change_requests", "admin_users"
  add_foreign_key "change_requests", "api_users"
  add_foreign_key "competition_files", "competitions"
  add_foreign_key "competitions", "events"
  add_foreign_key "competitions", "places"
  add_foreign_key "competitions", "score_types"
  add_foreign_key "group_score_categories", "competitions"
  add_foreign_key "group_score_categories", "group_score_types"
  add_foreign_key "group_scores", "group_score_categories"
  add_foreign_key "group_scores", "teams"
  add_foreign_key "import_request_files", "import_requests"
  add_foreign_key "people", "nations"
  add_foreign_key "person_participations", "group_scores"
  add_foreign_key "person_participations", "people"
  add_foreign_key "person_spellings", "people"
  add_foreign_key "registrations_assessment_participations", "registrations_assessments", column: "assessment_id"
  add_foreign_key "registrations_assessment_participations", "registrations_people", column: "person_id"
  add_foreign_key "registrations_assessment_participations", "registrations_teams", column: "team_id"
  add_foreign_key "registrations_assessments", "registrations_competitions", column: "competition_id"
  add_foreign_key "registrations_competitions", "admin_users"
  add_foreign_key "registrations_people", "admin_users"
  add_foreign_key "registrations_people", "people"
  add_foreign_key "registrations_people", "registrations_competitions", column: "competition_id"
  add_foreign_key "registrations_people", "registrations_teams", column: "team_id"
  add_foreign_key "registrations_teams", "admin_users"
  add_foreign_key "registrations_teams", "registrations_competitions", column: "competition_id"
  add_foreign_key "registrations_teams", "teams"
  add_foreign_key "scores", "competitions"
  add_foreign_key "scores", "people"
  add_foreign_key "scores", "teams"
  add_foreign_key "series_assessments", "series_rounds", column: "round_id"
  add_foreign_key "series_cups", "competitions"
  add_foreign_key "series_cups", "series_rounds", column: "round_id"
  add_foreign_key "series_participations", "people"
  add_foreign_key "series_participations", "series_assessments", column: "assessment_id"
  add_foreign_key "series_participations", "series_cups", column: "cup_id"
  add_foreign_key "series_participations", "teams"
  add_foreign_key "series_rounds", "series_kinds", column: "kind_id"
  add_foreign_key "team_spellings", "teams"
end
