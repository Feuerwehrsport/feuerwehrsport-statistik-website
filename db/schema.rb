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

ActiveRecord::Schema.define(version: 20170829114824) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "admin_users", force: :cascade do |t|
    t.string   "name",                   :null=>false
    t.string   "role",                   :default=>"user", :null=>false
    t.string   "email",                  :default=>"", :null=>false
    t.string   "encrypted_password",     :default=>"", :null=>false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default=>0, :null=>false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.integer  "failed_attempts",        :default=>0, :null=>false
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at",             :null=>false
    t.datetime "updated_at",             :null=>false
  end
  add_index "admin_users", ["confirmation_token"], :name=>"index_admin_users_on_confirmation_token", :unique=>true, :using=>:btree
  add_index "admin_users", ["email"], :name=>"index_admin_users_on_email", :unique=>true, :using=>:btree
  add_index "admin_users", ["reset_password_token"], :name=>"index_admin_users_on_reset_password_token", :unique=>true, :using=>:btree
  add_index "admin_users", ["unlock_token"], :name=>"index_admin_users_on_unlock_token", :unique=>true, :using=>:btree

  create_table "api_users", force: :cascade do |t|
    t.string   "name"
    t.string   "email_address"
    t.string   "ip_address_hash"
    t.string   "user_agent_hash"
    t.string   "user_agent_meta"
    t.datetime "created_at",      :null=>false
    t.datetime "updated_at",      :null=>false
  end

  create_table "appointments", force: :cascade do |t|
    t.date     "dated_at",     :null=>false
    t.string   "name",         :null=>false
    t.text     "description",  :null=>false
    t.integer  "place_id"
    t.integer  "event_id"
    t.string   "disciplines",  :default=>"", :null=>false
    t.datetime "created_at",   :null=>false
    t.datetime "updated_at",   :null=>false
    t.integer  "creator_id"
    t.string   "creator_type"
  end
  add_index "appointments", ["event_id"], :name=>"index_appointments_on_event_id", :using=>:btree
  add_index "appointments", ["place_id"], :name=>"index_appointments_on_place_id", :using=>:btree

  create_table "change_logs", force: :cascade do |t|
    t.integer  "admin_user_id"
    t.integer  "api_user_id"
    t.string   "model_class",   :null=>false
    t.string   "action_name",   :null=>false
    t.string   "log_action"
    t.json     "content",       :null=>false
    t.datetime "created_at",    :null=>false
    t.datetime "updated_at",    :null=>false
  end
  add_index "change_logs", ["admin_user_id"], :name=>"index_change_logs_on_admin_user_id", :using=>:btree
  add_index "change_logs", ["api_user_id"], :name=>"index_change_logs_on_api_user_id", :using=>:btree

  create_table "change_requests", force: :cascade do |t|
    t.integer  "api_user_id"
    t.integer  "admin_user_id"
    t.json     "content",       :null=>false
    t.datetime "done_at"
    t.datetime "created_at",    :null=>false
    t.datetime "updated_at",    :null=>false
    t.json     "files_data",    :default=>{}, :null=>false
  end
  add_index "change_requests", ["admin_user_id"], :name=>"index_change_requests_on_admin_user_id", :using=>:btree
  add_index "change_requests", ["api_user_id"], :name=>"index_change_requests_on_api_user_id", :using=>:btree

  create_table "comp_reg_assessment_participations", force: :cascade do |t|
    t.string   "type",                      :null=>false
    t.integer  "competition_assessment_id", :null=>false
    t.integer  "team_id"
    t.integer  "person_id"
    t.integer  "assessment_type",           :default=>0, :null=>false
    t.integer  "single_competitor_order",   :default=>0, :null=>false
    t.integer  "group_competitor_order",    :default=>0, :null=>false
    t.datetime "created_at",                :null=>false
    t.datetime "updated_at",                :null=>false
  end

  create_table "comp_reg_competition_assessments", force: :cascade do |t|
    t.integer  "competition_id", :null=>false
    t.string   "discipline",     :null=>false
    t.string   "name",           :default=>"", :null=>false
    t.integer  "gender",         :null=>false
    t.datetime "created_at",     :null=>false
    t.datetime "updated_at",     :null=>false
  end

  create_table "comp_reg_competitions", force: :cascade do |t|
    t.string   "name",          :null=>false
    t.date     "date",          :null=>false
    t.string   "place",         :null=>false
    t.text     "description",   :default=>"", :null=>false
    t.datetime "open_at"
    t.datetime "close_at"
    t.integer  "admin_user_id", :null=>false
    t.string   "person_tags",   :default=>"", :null=>false
    t.string   "team_tags",     :default=>"", :null=>false
    t.datetime "created_at",    :null=>false
    t.datetime "updated_at",    :null=>false
    t.string   "slug"
    t.boolean  "published",     :default=>false, :null=>false
    t.boolean  "group_score",   :default=>false, :null=>false
  end
  add_index "comp_reg_competitions", ["slug"], :name=>"index_comp_reg_competitions_on_slug", :unique=>true, :using=>:btree

  create_table "comp_reg_competitions_mails", force: :cascade do |t|
    t.integer  "competition_id"
    t.integer  "admin_user_id"
    t.boolean  "add_registration_file", :default=>true, :null=>false
    t.string   "subject"
    t.text     "text"
    t.datetime "created_at",            :null=>false
    t.datetime "updated_at",            :null=>false
  end
  add_index "comp_reg_competitions_mails", ["admin_user_id"], :name=>"index_comp_reg_competitions_mails_on_admin_user_id", :using=>:btree
  add_index "comp_reg_competitions_mails", ["competition_id"], :name=>"index_comp_reg_competitions_mails_on_competition_id", :using=>:btree

  create_table "comp_reg_people", force: :cascade do |t|
    t.integer  "competition_id",     :null=>false
    t.integer  "team_id"
    t.integer  "person_id"
    t.integer  "admin_user_id",      :null=>false
    t.string   "first_name",         :null=>false
    t.string   "last_name",          :null=>false
    t.integer  "gender",             :null=>false
    t.datetime "created_at",         :null=>false
    t.datetime "updated_at",         :null=>false
    t.integer  "registration_order", :default=>0, :null=>false
    t.string   "team_name"
  end

  create_table "comp_reg_teams", force: :cascade do |t|
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
    t.datetime "created_at",               :null=>false
    t.datetime "updated_at",               :null=>false
    t.integer  "federal_state_id"
  end

  create_table "competition_files", force: :cascade do |t|
    t.integer  "competition_id"
    t.string   "file"
    t.string   "keys_string"
    t.datetime "created_at",     :null=>false
    t.datetime "updated_at",     :null=>false
  end
  add_index "competition_files", ["competition_id"], :name=>"index_competition_files_on_competition_id", :using=>:btree

  create_table "group_score_categories", force: :cascade do |t|
    t.integer  "group_score_type_id", :null=>false
    t.integer  "competition_id",      :null=>false
    t.string   "name",                :null=>false
    t.datetime "created_at",          :null=>false
    t.datetime "updated_at",          :null=>false
  end
  add_index "group_score_categories", ["competition_id"], :name=>"index_group_score_categories_on_competition_id", :using=>:btree
  add_index "group_score_categories", ["group_score_type_id"], :name=>"index_group_score_categories_on_group_score_type_id", :using=>:btree

  create_table "group_scores", force: :cascade do |t|
    t.integer  "team_id",                 :null=>false
    t.integer  "team_number",             :default=>0, :null=>false
    t.integer  "gender",                  :null=>false
    t.integer  "time",                    :null=>false
    t.integer  "group_score_category_id", :null=>false
    t.string   "run",                     :null=>false
    t.datetime "created_at",              :null=>false
    t.datetime "updated_at",              :null=>false
  end
  add_index "group_scores", ["group_score_category_id"], :name=>"index_group_scores_on_group_score_category_id", :using=>:btree
  add_index "group_scores", ["team_id"], :name=>"index_group_scores_on_team_id", :using=>:btree

  create_table "people", force: :cascade do |t|
    t.string   "last_name",  :null=>false
    t.string   "first_name", :null=>false
    t.integer  "gender",     :null=>false
    t.integer  "nation_id",  :null=>false
    t.datetime "created_at", :null=>false
    t.datetime "updated_at", :null=>false
    t.integer  "hb_count",   :default=>0, :null=>false
    t.integer  "hl_count",   :default=>0, :null=>false
    t.integer  "la_count",   :default=>0, :null=>false
    t.integer  "fs_count",   :default=>0, :null=>false
    t.integer  "gs_count",   :default=>0, :null=>false
  end
  add_index "people", ["gender"], :name=>"index_people_on_gender", :using=>:btree
  add_index "people", ["nation_id"], :name=>"index_people_on_nation_id", :using=>:btree

  create_table "scores", force: :cascade do |t|
    t.integer  "person_id",      :null=>false
    t.string   "discipline",     :null=>false
    t.integer  "competition_id", :null=>false
    t.integer  "time",           :null=>false
    t.integer  "team_id"
    t.integer  "team_number",    :default=>0, :null=>false
    t.datetime "created_at",     :null=>false
    t.datetime "updated_at",     :null=>false
  end
  add_index "scores", ["competition_id"], :name=>"index_scores_on_competition_id", :using=>:btree
  add_index "scores", ["person_id"], :name=>"index_scores_on_person_id", :using=>:btree
  add_index "scores", ["team_id"], :name=>"index_scores_on_team_id", :using=>:btree

  create_view "competition_team_numbers", <<-'END_VIEW_COMPETITION_TEAM_NUMBERS', :force => true
SELECT group_scores.team_id,
    group_scores.team_number,
    group_scores.gender,
    group_score_categories.competition_id
   FROM (group_scores
     JOIN group_score_categories ON ((group_score_categories.id = group_scores.group_score_category_id)))
  WHERE (group_scores.team_number > 0)
UNION
 SELECT scores.team_id,
    scores.team_number,
    people.gender,
    scores.competition_id
   FROM (scores
     JOIN people ON ((people.id = scores.person_id)))
  WHERE ((scores.team_number > 0) AND (scores.team_id IS NOT NULL))
  END_VIEW_COMPETITION_TEAM_NUMBERS

  create_table "competitions", force: :cascade do |t|
    t.string   "name",          :default=>"", :null=>false
    t.integer  "place_id",      :null=>false
    t.integer  "event_id",      :null=>false
    t.integer  "score_type_id"
    t.date     "date",          :null=>false
    t.datetime "published_at"
    t.datetime "created_at",    :null=>false
    t.datetime "updated_at",    :null=>false
    t.text     "hint_content",  :default=>"", :null=>false
    t.integer  "hl_female",     :default=>0, :null=>false
    t.integer  "hl_male",       :default=>0, :null=>false
    t.integer  "hb_female",     :default=>0, :null=>false
    t.integer  "hb_male",       :default=>0, :null=>false
    t.integer  "gs",            :default=>0, :null=>false
    t.integer  "fs_female",     :default=>0, :null=>false
    t.integer  "fs_male",       :default=>0, :null=>false
    t.integer  "la_female",     :default=>0, :null=>false
    t.integer  "la_male",       :default=>0, :null=>false
    t.integer  "teams_count",   :default=>0, :null=>false
    t.integer  "people_count",  :default=>0, :null=>false
  end
  add_index "competitions", ["event_id"], :name=>"index_competitions_on_event_id", :using=>:btree
  add_index "competitions", ["place_id"], :name=>"index_competitions_on_place_id", :using=>:btree
  add_index "competitions", ["score_type_id"], :name=>"index_competitions_on_score_type_id", :using=>:btree

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   :default=>0, :null=>false
    t.integer  "attempts",   :default=>0, :null=>false
    t.text     "handler",    :null=>false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end
  add_index "delayed_jobs", ["priority", "run_at"], :name=>"delayed_jobs_priority", :using=>:btree

  create_table "entity_merges", force: :cascade do |t|
    t.integer  "source_id",   :null=>false
    t.string   "source_type", :null=>false
    t.integer  "target_id",   :null=>false
    t.string   "target_type", :null=>false
    t.datetime "created_at",  :null=>false
    t.datetime "updated_at",  :null=>false
  end
  add_index "entity_merges", ["source_type", "source_id"], :name=>"index_entity_merges_on_source_type_and_source_id", :using=>:btree
  add_index "entity_merges", ["target_type", "target_id"], :name=>"index_entity_merges_on_target_type_and_target_id", :using=>:btree

  create_table "events", force: :cascade do |t|
    t.string   "name",       :null=>false
    t.datetime "created_at", :null=>false
    t.datetime "updated_at", :null=>false
  end

  create_table "federal_states", force: :cascade do |t|
    t.string   "name",       :null=>false
    t.string   "shortcut",   :null=>false
    t.datetime "created_at", :null=>false
    t.datetime "updated_at", :null=>false
  end

  create_table "group_score_types", force: :cascade do |t|
    t.string   "discipline", :null=>false
    t.string   "name",       :null=>false
    t.boolean  "regular",    :default=>false, :null=>false
    t.datetime "created_at", :null=>false
    t.datetime "updated_at", :null=>false
  end

  create_table "person_participations", force: :cascade do |t|
    t.integer  "person_id",      :null=>false
    t.integer  "group_score_id", :null=>false
    t.integer  "position",       :null=>false
    t.datetime "created_at",     :null=>false
    t.datetime "updated_at",     :null=>false
  end
  add_index "person_participations", ["group_score_id"], :name=>"index_person_participations_on_group_score_id", :using=>:btree
  add_index "person_participations", ["person_id"], :name=>"index_person_participations_on_person_id", :using=>:btree

  create_view "group_score_participations", <<-'END_VIEW_GROUP_SCORE_PARTICIPATIONS', :force => true
SELECT person_participations.person_id,
    group_scores.team_id,
    group_scores.team_number,
    group_score_categories.competition_id,
    group_score_categories.group_score_type_id,
    group_score_types.discipline,
    group_scores."time",
    person_participations."position"
   FROM (((person_participations
     JOIN group_scores ON ((group_scores.id = person_participations.group_score_id)))
     JOIN group_score_categories ON ((group_score_categories.id = group_scores.group_score_category_id)))
     JOIN group_score_types ON ((group_score_types.id = group_score_categories.group_score_type_id)))
  END_VIEW_GROUP_SCORE_PARTICIPATIONS

  create_table "import_requests", force: :cascade do |t|
    t.string   "file"
    t.string   "url"
    t.date     "date"
    t.integer  "place_id"
    t.integer  "event_id"
    t.text     "description"
    t.integer  "admin_user_id"
    t.integer  "edit_user_id"
    t.datetime "edited_at"
    t.datetime "finished_at"
    t.datetime "created_at",    :null=>false
    t.datetime "updated_at",    :null=>false
  end
  add_index "import_requests", ["admin_user_id"], :name=>"index_import_requests_on_admin_user_id", :using=>:btree
  add_index "import_requests", ["edit_user_id"], :name=>"index_import_requests_on_edit_user_id", :using=>:btree
  add_index "import_requests", ["event_id"], :name=>"index_import_requests_on_event_id", :using=>:btree
  add_index "import_requests", ["place_id"], :name=>"index_import_requests_on_place_id", :using=>:btree

  create_table "links", force: :cascade do |t|
    t.string   "label"
    t.integer  "linkable_id"
    t.string   "linkable_type"
    t.text     "url"
    t.datetime "created_at",    :null=>false
    t.datetime "updated_at",    :null=>false
  end

  create_table "nations", force: :cascade do |t|
    t.string   "name",       :null=>false
    t.string   "iso",        :null=>false
    t.datetime "created_at", :null=>false
    t.datetime "updated_at", :null=>false
  end

  create_table "news", force: :cascade do |t|
    t.string   "title"
    t.integer  "admin_user_id"
    t.string   "content"
    t.datetime "published_at"
    t.datetime "created_at",    :null=>false
    t.datetime "updated_at",    :null=>false
  end
  add_index "news", ["admin_user_id"], :name=>"index_news_on_admin_user_id", :using=>:btree

  create_table "person_spellings", force: :cascade do |t|
    t.integer  "person_id",  :null=>false
    t.string   "last_name",  :null=>false
    t.string   "first_name", :null=>false
    t.integer  "gender",     :null=>false
    t.boolean  "official",   :default=>false, :null=>false
    t.datetime "created_at", :null=>false
    t.datetime "updated_at", :null=>false
  end
  add_index "person_spellings", ["person_id"], :name=>"index_person_spellings_on_person_id", :using=>:btree

  create_table "places", force: :cascade do |t|
    t.string   "name",       :null=>false
    t.decimal  "latitude",   :precision=>15, :scale=>10
    t.decimal  "longitude",  :precision=>15, :scale=>10
    t.datetime "created_at", :null=>false
    t.datetime "updated_at", :null=>false
  end

  create_view "score_double_events", <<-'END_VIEW_SCORE_DOUBLE_EVENTS', :force => true
SELECT DISTINCT ON ((concat(hb_scores.competition_id, '-', hb_scores.person_id))) hb_scores.person_id,
    hb_scores.competition_id,
    hb_scores."time" AS hb,
    hl_scores."time" AS hl,
    (hb_scores."time" + hl_scores."time") AS "time"
   FROM (( SELECT scores."time",
            scores.competition_id,
            scores.person_id
           FROM scores
          WHERE ((scores."time" <> 99999999) AND ((scores.discipline)::text = 'hb'::text) AND (scores.team_number >= 0))) hb_scores
     JOIN ( SELECT scores."time",
            scores.competition_id,
            scores.person_id
           FROM scores
          WHERE ((scores."time" <> 99999999) AND ((scores.discipline)::text = 'hl'::text) AND (scores.team_number >= 0))) hl_scores ON (((hb_scores.competition_id = hl_scores.competition_id) AND (hb_scores.person_id = hl_scores.person_id))))
  ORDER BY (concat(hb_scores.competition_id, '-', hb_scores.person_id)), (hb_scores."time" + hl_scores."time")
  END_VIEW_SCORE_DOUBLE_EVENTS

  create_view "score_low_double_events", <<-'END_VIEW_SCORE_LOW_DOUBLE_EVENTS', :force => true
SELECT DISTINCT ON ((concat(hb_scores.competition_id, '-', hb_scores.person_id))) hb_scores.person_id,
    hb_scores.competition_id,
    hb_scores."time" AS hb,
    hl_scores."time" AS hl,
    (hb_scores."time" + hl_scores."time") AS "time"
   FROM (( SELECT scores."time",
            scores.competition_id,
            scores.person_id
           FROM scores
          WHERE ((scores."time" <> 99999999) AND ((scores.discipline)::text = 'hw'::text) AND (scores.team_number >= 0))) hb_scores
     JOIN ( SELECT scores."time",
            scores.competition_id,
            scores.person_id
           FROM scores
          WHERE ((scores."time" <> 99999999) AND ((scores.discipline)::text = 'hl'::text) AND (scores.team_number >= 0))) hl_scores ON (((hb_scores.competition_id = hl_scores.competition_id) AND (hb_scores.person_id = hl_scores.person_id))))
  ORDER BY (concat(hb_scores.competition_id, '-', hb_scores.person_id)), (hb_scores."time" + hl_scores."time")
  END_VIEW_SCORE_LOW_DOUBLE_EVENTS

  create_table "score_types", force: :cascade do |t|
    t.integer  "people",     :null=>false
    t.integer  "run",        :null=>false
    t.integer  "score",      :null=>false
    t.datetime "created_at", :null=>false
    t.datetime "updated_at", :null=>false
  end

  create_table "series_assessments", force: :cascade do |t|
    t.integer  "round_id",   :null=>false
    t.string   "discipline", :null=>false
    t.string   "name",       :default=>"", :null=>false
    t.string   "type",       :null=>false
    t.integer  "gender",     :null=>false
    t.datetime "created_at", :null=>false
    t.datetime "updated_at", :null=>false
  end

  create_table "series_cups", force: :cascade do |t|
    t.integer  "round_id",       :null=>false
    t.integer  "competition_id", :null=>false
    t.datetime "created_at",     :null=>false
    t.datetime "updated_at",     :null=>false
  end

  create_table "series_participations", force: :cascade do |t|
    t.integer  "assessment_id", :null=>false
    t.integer  "cup_id",        :null=>false
    t.string   "type",          :null=>false
    t.integer  "team_id"
    t.integer  "team_number"
    t.integer  "person_id"
    t.integer  "time",          :null=>false
    t.integer  "points",        :default=>0, :null=>false
    t.integer  "rank",          :null=>false
    t.datetime "created_at",    :null=>false
    t.datetime "updated_at",    :null=>false
  end

  create_table "series_rounds", force: :cascade do |t|
    t.string   "name",           :null=>false
    t.integer  "year",           :null=>false
    t.string   "aggregate_type", :null=>false
    t.datetime "created_at",     :null=>false
    t.datetime "updated_at",     :null=>false
    t.boolean  "official",       :default=>false, :null=>false
    t.integer  "full_cup_count", :default=>4, :null=>false
  end

  create_table "tags", force: :cascade do |t|
    t.integer  "taggable_id",   :null=>false
    t.string   "taggable_type", :null=>false
    t.string   "name",          :null=>false
    t.datetime "created_at",    :null=>false
    t.datetime "updated_at",    :null=>false
  end

  create_view "team_competitions", <<-'END_VIEW_TEAM_COMPETITIONS', :force => true
SELECT group_scores.team_id,
    group_score_categories.competition_id
   FROM (group_scores
     JOIN group_score_categories ON ((group_score_categories.id = group_scores.group_score_category_id)))
UNION
 SELECT scores.team_id,
    scores.competition_id
   FROM scores
  WHERE (scores.team_id IS NOT NULL)
  END_VIEW_TEAM_COMPETITIONS

  create_view "team_members", <<-'END_VIEW_TEAM_MEMBERS', :force => true
SELECT group_scores.team_id,
    person_participations.person_id
   FROM (group_scores
     JOIN person_participations ON ((person_participations.group_score_id = group_scores.id)))
UNION
 SELECT scores.team_id,
    scores.person_id
   FROM scores
  WHERE (scores.team_id IS NOT NULL)
  END_VIEW_TEAM_MEMBERS

  create_table "team_spellings", force: :cascade do |t|
    t.integer  "team_id",    :null=>false
    t.string   "name",       :null=>false
    t.string   "shortcut",   :null=>false
    t.datetime "created_at", :null=>false
    t.datetime "updated_at", :null=>false
  end
  add_index "team_spellings", ["team_id"], :name=>"index_team_spellings_on_team_id", :using=>:btree

  create_table "teams", force: :cascade do |t|
    t.string   "name",       :null=>false
    t.string   "shortcut",   :null=>false
    t.integer  "status",     :null=>false
    t.decimal  "latitude",   :precision=>15, :scale=>10
    t.decimal  "longitude",  :precision=>15, :scale=>10
    t.string   "image"
    t.string   "state",      :default=>"", :null=>false
    t.datetime "created_at", :null=>false
    t.datetime "updated_at", :null=>false
  end

  create_view "years", <<-'END_VIEW_YEARS', :force => true
SELECT date_part('year'::text, competitions.date) AS year
   FROM competitions
  GROUP BY (date_part('year'::text, competitions.date))
  ORDER BY (date_part('year'::text, competitions.date)) DESC
  END_VIEW_YEARS

  add_foreign_key "appointments", "events"
  add_foreign_key "appointments", "places"
  add_foreign_key "change_logs", "admin_users"
  add_foreign_key "change_logs", "api_users"
  add_foreign_key "change_requests", "admin_users"
  add_foreign_key "change_requests", "api_users"
  add_foreign_key "comp_reg_assessment_participations", "comp_reg_competition_assessments", column: "competition_assessment_id"
  add_foreign_key "comp_reg_assessment_participations", "comp_reg_people", column: "person_id"
  add_foreign_key "comp_reg_assessment_participations", "comp_reg_teams", column: "team_id"
  add_foreign_key "comp_reg_competition_assessments", "comp_reg_competitions", column: "competition_id"
  add_foreign_key "comp_reg_competitions", "admin_users"
  add_foreign_key "comp_reg_competitions_mails", "admin_users"
  add_foreign_key "comp_reg_competitions_mails", "comp_reg_competitions", column: "competition_id"
  add_foreign_key "comp_reg_people", "admin_users"
  add_foreign_key "comp_reg_people", "comp_reg_competitions", column: "competition_id"
  add_foreign_key "comp_reg_people", "comp_reg_teams", column: "team_id"
  add_foreign_key "comp_reg_people", "people"
  add_foreign_key "comp_reg_teams", "admin_users"
  add_foreign_key "comp_reg_teams", "comp_reg_competitions", column: "competition_id"
  add_foreign_key "comp_reg_teams", "teams"
  add_foreign_key "competition_files", "competitions"
  add_foreign_key "competitions", "events"
  add_foreign_key "competitions", "places"
  add_foreign_key "competitions", "score_types"
  add_foreign_key "group_score_categories", "competitions"
  add_foreign_key "group_score_categories", "group_score_types"
  add_foreign_key "group_scores", "group_score_categories"
  add_foreign_key "group_scores", "teams"
  add_foreign_key "news", "admin_users"
  add_foreign_key "people", "nations"
  add_foreign_key "person_participations", "group_scores"
  add_foreign_key "person_participations", "people"
  add_foreign_key "person_spellings", "people"
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
  add_foreign_key "team_spellings", "teams"
end
