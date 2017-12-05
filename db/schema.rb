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

ActiveRecord::Schema.define(version: 20171120163010) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "admin_users", force: :cascade do |t|
    t.string   "role",       :limit=>200, :default=>"user", :null=>false
    t.datetime "created_at", :null=>false
    t.datetime "updated_at", :null=>false
    t.integer  "login_id",   :null=>false, :index=>{:name=>"index_admin_users_on_login_id", :using=>:btree}
  end

  create_table "api_users", force: :cascade do |t|
    t.string   "name",            :limit=>200, :null=>false
    t.string   "email_address",   :limit=>200
    t.string   "ip_address_hash", :limit=>200, :null=>false
    t.string   "user_agent_hash", :limit=>200, :null=>false
    t.string   "user_agent_meta", :limit=>1000
    t.datetime "created_at",      :null=>false
    t.datetime "updated_at",      :null=>false
  end

  create_table "appointments", force: :cascade do |t|
    t.date     "dated_at",     :null=>false
    t.string   "name",         :limit=>200, :null=>false
    t.text     "description",  :null=>false
    t.integer  "place_id",     :index=>{:name=>"index_appointments_on_place_id", :using=>:btree}
    t.integer  "event_id",     :index=>{:name=>"index_appointments_on_event_id", :using=>:btree}
    t.string   "disciplines",  :limit=>200, :default=>"", :null=>false
    t.datetime "created_at",   :null=>false
    t.datetime "updated_at",   :null=>false
    t.integer  "creator_id"
    t.string   "creator_type"
  end

  create_table "bla_badges", force: :cascade do |t|
    t.integer  "person_id",   :null=>false, :index=>{:name=>"index_bla_badges_on_person_id", :unique=>true, :using=>:btree}
    t.string   "status",      :limit=>200, :null=>false
    t.integer  "year",        :null=>false
    t.integer  "hl_time"
    t.integer  "hl_score_id", :index=>{:name=>"index_bla_badges_on_hl_score_id", :using=>:btree}
    t.integer  "hb_time",     :null=>false
    t.integer  "hb_score_id", :index=>{:name=>"index_bla_badges_on_hb_score_id", :using=>:btree}
    t.datetime "created_at",  :null=>false
    t.datetime "updated_at",  :null=>false
  end

  create_table "change_logs", force: :cascade do |t|
    t.integer  "admin_user_id", :index=>{:name=>"index_change_logs_on_admin_user_id", :using=>:btree}
    t.integer  "api_user_id",   :index=>{:name=>"index_change_logs_on_api_user_id", :using=>:btree}
    t.string   "model_class",   :null=>false
    t.json     "content",       :null=>false
    t.datetime "created_at",    :null=>false
    t.datetime "updated_at",    :null=>false
    t.string   "action",        :null=>false
  end

  create_table "change_requests", force: :cascade do |t|
    t.integer  "api_user_id",   :index=>{:name=>"index_change_requests_on_api_user_id", :using=>:btree}
    t.integer  "admin_user_id", :index=>{:name=>"index_change_requests_on_admin_user_id", :using=>:btree}
    t.json     "content",       :null=>false
    t.datetime "done_at"
    t.datetime "created_at",    :null=>false
    t.datetime "updated_at",    :null=>false
    t.json     "files_data",    :default=>{}
  end

  create_table "competition_files", force: :cascade do |t|
    t.integer  "competition_id", :null=>false, :index=>{:name=>"index_competition_files_on_competition_id", :using=>:btree}
    t.string   "file",           :null=>false
    t.string   "keys_string",    :limit=>200
    t.datetime "created_at",     :null=>false
    t.datetime "updated_at",     :null=>false
  end

  create_table "group_score_categories", force: :cascade do |t|
    t.integer  "group_score_type_id", :null=>false, :index=>{:name=>"index_group_score_categories_on_group_score_type_id", :using=>:btree}
    t.integer  "competition_id",      :null=>false, :index=>{:name=>"index_group_score_categories_on_competition_id", :using=>:btree}
    t.string   "name",                :limit=>200, :null=>false
    t.datetime "created_at",          :null=>false
    t.datetime "updated_at",          :null=>false
  end

  create_table "group_scores", force: :cascade do |t|
    t.integer  "team_id",                 :null=>false, :index=>{:name=>"index_group_scores_on_team_id", :using=>:btree}
    t.integer  "team_number",             :default=>0, :null=>false
    t.integer  "gender",                  :null=>false
    t.integer  "time",                    :null=>false
    t.integer  "group_score_category_id", :null=>false, :index=>{:name=>"index_group_scores_on_group_score_category_id", :using=>:btree}
    t.string   "run",                     :limit=>1
    t.datetime "created_at",              :null=>false
    t.datetime "updated_at",              :null=>false
  end

  create_table "people", force: :cascade do |t|
    t.string   "last_name",  :limit=>200, :null=>false
    t.string   "first_name", :limit=>200, :null=>false
    t.integer  "gender",     :null=>false, :index=>{:name=>"index_people_on_gender", :using=>:btree}
    t.integer  "nation_id",  :null=>false, :index=>{:name=>"index_people_on_nation_id", :using=>:btree}
    t.datetime "created_at", :null=>false
    t.datetime "updated_at", :null=>false
    t.integer  "hb_count",   :default=>0, :null=>false
    t.integer  "hl_count",   :default=>0, :null=>false
    t.integer  "la_count",   :default=>0, :null=>false
    t.integer  "fs_count",   :default=>0, :null=>false
    t.integer  "gs_count",   :default=>0, :null=>false
  end

  create_table "scores", force: :cascade do |t|
    t.integer  "person_id",      :null=>false, :index=>{:name=>"index_scores_on_person_id", :using=>:btree}
    t.string   "discipline",     :null=>false
    t.integer  "competition_id", :null=>false, :index=>{:name=>"index_scores_on_competition_id", :using=>:btree}
    t.integer  "time",           :null=>false
    t.integer  "team_id",        :index=>{:name=>"index_scores_on_team_id", :using=>:btree}
    t.integer  "team_number",    :default=>0, :null=>false
    t.datetime "created_at",     :null=>false
    t.datetime "updated_at",     :null=>false
  end

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
    t.string   "name",                 :limit=>200, :default=>"", :null=>false
    t.integer  "place_id",             :null=>false, :index=>{:name=>"index_competitions_on_place_id", :using=>:btree}
    t.integer  "event_id",             :null=>false, :index=>{:name=>"index_competitions_on_event_id", :using=>:btree}
    t.integer  "score_type_id",        :index=>{:name=>"index_competitions_on_score_type_id", :using=>:btree}
    t.date     "date",                 :null=>false
    t.datetime "published_at"
    t.datetime "created_at",           :null=>false
    t.datetime "updated_at",           :null=>false
    t.text     "hint_content",         :default=>"", :null=>false
    t.integer  "hl_female",            :default=>0, :null=>false
    t.integer  "hl_male",              :default=>0, :null=>false
    t.integer  "hb_female",            :default=>0, :null=>false
    t.integer  "hb_male",              :default=>0, :null=>false
    t.integer  "gs",                   :default=>0, :null=>false
    t.integer  "fs_female",            :default=>0, :null=>false
    t.integer  "fs_male",              :default=>0, :null=>false
    t.integer  "la_female",            :default=>0, :null=>false
    t.integer  "la_male",              :default=>0, :null=>false
    t.integer  "teams_count",          :default=>0, :null=>false
    t.integer  "people_count",         :default=>0, :null=>false
    t.boolean  "scores_for_bla_badge", :default=>false, :null=>false
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   :default=>0, :null=>false, :index=>{:name=>"delayed_jobs_priority", :with=>["run_at"], :using=>:btree}
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

  create_table "entity_merges", force: :cascade do |t|
    t.integer  "source_id",   :null=>false
    t.string   "source_type", :null=>false, :index=>{:name=>"index_entity_merges_on_source_type_and_source_id", :with=>["source_id"], :using=>:btree}
    t.integer  "target_id",   :null=>false
    t.string   "target_type", :null=>false, :index=>{:name=>"index_entity_merges_on_target_type_and_target_id", :with=>["target_id"], :using=>:btree}
    t.datetime "created_at",  :null=>false
    t.datetime "updated_at",  :null=>false
  end

  create_table "events", force: :cascade do |t|
    t.string   "name",       :limit=>200, :null=>false
    t.datetime "created_at", :null=>false
    t.datetime "updated_at", :null=>false
  end

  create_table "federal_states", force: :cascade do |t|
    t.string   "name",       :limit=>200, :null=>false
    t.string   "shortcut",   :limit=>10, :null=>false
    t.datetime "created_at", :null=>false
    t.datetime "updated_at", :null=>false
  end

  create_table "group_score_types", force: :cascade do |t|
    t.string   "discipline", :null=>false
    t.string   "name",       :limit=>200, :null=>false
    t.boolean  "regular",    :default=>false, :null=>false
    t.datetime "created_at", :null=>false
    t.datetime "updated_at", :null=>false
  end

  create_table "person_participations", force: :cascade do |t|
    t.integer  "person_id",      :null=>false, :index=>{:name=>"index_person_participations_on_person_id", :using=>:btree}
    t.integer  "group_score_id", :null=>false, :index=>{:name=>"index_person_participations_on_group_score_id", :using=>:btree}
    t.integer  "position",       :null=>false
    t.datetime "created_at",     :null=>false
    t.datetime "updated_at",     :null=>false
  end

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
    t.integer  "place_id",      :index=>{:name=>"index_import_requests_on_place_id", :using=>:btree}
    t.integer  "event_id",      :index=>{:name=>"index_import_requests_on_event_id", :using=>:btree}
    t.text     "description"
    t.integer  "admin_user_id", :index=>{:name=>"index_import_requests_on_admin_user_id", :using=>:btree}
    t.integer  "edit_user_id",  :index=>{:name=>"index_import_requests_on_edit_user_id", :using=>:btree}
    t.datetime "edited_at"
    t.datetime "finished_at"
    t.datetime "created_at",    :null=>false
    t.datetime "updated_at",    :null=>false
  end

  create_table "links", force: :cascade do |t|
    t.string   "label",         :null=>false
    t.integer  "linkable_id",   :null=>false
    t.string   "linkable_type", :null=>false
    t.text     "url",           :null=>false
    t.datetime "created_at",    :null=>false
    t.datetime "updated_at",    :null=>false
  end

  create_table "m3_assets", force: :cascade do |t|
    t.integer  "website_id", :null=>false, :index=>{:name=>"index_m3_assets_on_website_id", :using=>:btree}
    t.string   "file"
    t.string   "name",       :limit=>200
    t.boolean  "image",      :default=>false, :null=>false
    t.datetime "created_at", :null=>false
    t.datetime "updated_at", :null=>false
  end

  create_table "m3_delivery_settings", force: :cascade do |t|
    t.integer  "website_id",           :null=>false, :index=>{:name=>"index_m3_delivery_settings_on_website_id", :using=>:btree}
    t.string   "delivery_method",      :default=>"file", :null=>false
    t.string   "address"
    t.integer  "port"
    t.string   "domain"
    t.string   "user_name"
    t.string   "password"
    t.string   "authentication"
    t.boolean  "enable_starttls_auto"
    t.boolean  "tls"
    t.string   "openssl_verify_mode"
    t.string   "location"
    t.string   "arguments"
    t.string   "from_address"
    t.string   "from_name"
    t.string   "reply_to_address"
    t.string   "reply_to_name"
    t.datetime "created_at",           :null=>false
    t.datetime "updated_at",           :null=>false
  end

  create_table "m3_logins", force: :cascade do |t|
    t.string   "name"
    t.string   "email_address",                      :null=>false
    t.string   "password_digest"
    t.datetime "verified_at"
    t.string   "verify_token",                       :index=>{:name=>"index_m3_logins_on_verify_token", :unique=>true, :using=>:btree}
    t.integer  "website_id",                         :null=>false, :index=>{:name=>"index_m3_logins_on_website_id", :using=>:btree}
    t.datetime "created_at",                         :null=>false
    t.datetime "updated_at",                         :null=>false
    t.datetime "password_reset_requested_at"
    t.string   "password_reset_token",               :index=>{:name=>"index_m3_logins_on_password_reset_token", :unique=>true, :using=>:btree}
    t.datetime "deleted_at",                         :index=>{:name=>"index_m3_logins_on_deleted_at", :using=>:btree}
    t.datetime "expired_at"
    t.string   "changed_email_address"
    t.string   "changed_email_address_token",        :null=>false, :index=>{:name=>"index_m3_logins_on_changed_email_address_token", :unique=>true, :using=>:btree}
    t.datetime "changed_email_address_requested_at"
  end

  create_table "m3_websites", force: :cascade do |t|
    t.string   "name",                   :null=>false
    t.string   "domain",                 :null=>false
    t.string   "title",                  :null=>false
    t.datetime "created_at",             :null=>false
    t.datetime "updated_at",             :null=>false
    t.integer  "port",                   :default=>80, :null=>false
    t.string   "protocol",               :default=>"http", :null=>false
    t.boolean  "default_site",           :default=>false, :null=>false
    t.string   "google_tag_manager_key", :limit=>200
    t.string   "facebook_pixel_id",      :limit=>200
    t.string   "google_analytics_key",   :limit=>200
    t.string   "key",                    :limit=>200, :null=>false, :index=>{:name=>"index_m3_websites_on_key", :unique=>true, :using=>:btree}
  end

  create_table "nations", force: :cascade do |t|
    t.string   "name",       :limit=>200, :null=>false
    t.string   "iso",        :limit=>10, :null=>false
    t.datetime "created_at", :null=>false
    t.datetime "updated_at", :null=>false
  end

  create_table "news_articles", force: :cascade do |t|
    t.string   "title",         :limit=>200, :null=>false
    t.integer  "admin_user_id", :null=>false, :index=>{:name=>"index_news_articles_on_admin_user_id", :using=>:btree}
    t.text     "content",       :null=>false
    t.date     "published_at",  :null=>false
    t.datetime "created_at",    :null=>false
    t.datetime "updated_at",    :null=>false
  end

  create_table "person_spellings", force: :cascade do |t|
    t.integer  "person_id",  :null=>false, :index=>{:name=>"index_person_spellings_on_person_id", :using=>:btree}
    t.string   "last_name",  :limit=>200, :null=>false
    t.string   "first_name", :limit=>200, :null=>false
    t.integer  "gender",     :null=>false
    t.boolean  "official",   :default=>false, :null=>false
    t.datetime "created_at", :null=>false
    t.datetime "updated_at", :null=>false
  end

  create_table "places", force: :cascade do |t|
    t.string   "name",       :limit=>200, :null=>false
    t.decimal  "latitude",   :precision=>15, :scale=>10
    t.decimal  "longitude",  :precision=>15, :scale=>10
    t.datetime "created_at", :null=>false
    t.datetime "updated_at", :null=>false
  end

  create_table "registrations_assessment_participations", force: :cascade do |t|
    t.string   "type",                    :null=>false
    t.integer  "assessment_id",           :null=>false
    t.integer  "team_id"
    t.integer  "person_id"
    t.integer  "assessment_type",         :default=>0, :null=>false
    t.integer  "single_competitor_order", :default=>0, :null=>false
    t.integer  "group_competitor_order",  :default=>0, :null=>false
    t.datetime "created_at",              :null=>false
    t.datetime "updated_at",              :null=>false
  end

  create_table "registrations_assessments", force: :cascade do |t|
    t.integer  "competition_id", :null=>false
    t.string   "discipline",     :null=>false
    t.string   "name",           :default=>"", :null=>false
    t.integer  "gender",         :null=>false
    t.datetime "created_at",     :null=>false
    t.datetime "updated_at",     :null=>false
  end

  create_table "registrations_competitions", force: :cascade do |t|
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
    t.string   "slug",          :index=>{:name=>"index_registrations_competitions_on_slug", :unique=>true, :using=>:btree}
    t.boolean  "published",     :default=>false, :null=>false
    t.boolean  "group_score",   :default=>false, :null=>false
  end

  create_table "registrations_competitions_mails", force: :cascade do |t|
    t.integer  "competition_id",        :index=>{:name=>"index_registrations_competitions_mails_on_competition_id", :using=>:btree}
    t.integer  "admin_user_id",         :index=>{:name=>"index_registrations_competitions_mails_on_admin_user_id", :using=>:btree}
    t.boolean  "add_registration_file", :default=>true, :null=>false
    t.string   "subject"
    t.text     "text"
    t.datetime "created_at",            :null=>false
    t.datetime "updated_at",            :null=>false
  end

  create_table "registrations_people", force: :cascade do |t|
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

  create_table "registrations_teams", force: :cascade do |t|
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
    t.string   "discipline", :limit=>3, :null=>false
    t.string   "name",       :limit=>200, :default=>"", :null=>false
    t.string   "type",       :limit=>200, :null=>false
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
    t.integer  "team_id",    :null=>false, :index=>{:name=>"index_team_spellings_on_team_id", :using=>:btree}
    t.string   "name",       :limit=>200, :null=>false
    t.string   "shortcut",   :limit=>200, :null=>false
    t.datetime "created_at", :null=>false
    t.datetime "updated_at", :null=>false
  end

  create_table "teams", force: :cascade do |t|
    t.string   "name",       :limit=>200, :null=>false
    t.string   "shortcut",   :limit=>200, :null=>false
    t.integer  "status",     :null=>false
    t.decimal  "latitude",   :precision=>15, :scale=>10
    t.decimal  "longitude",  :precision=>15, :scale=>10
    t.string   "image"
    t.string   "state",      :limit=>200, :default=>"", :null=>false
    t.datetime "created_at", :null=>false
    t.datetime "updated_at", :null=>false
  end

  create_view "years", <<-'END_VIEW_YEARS', :force => true
SELECT date_part('year'::text, competitions.date) AS year
   FROM competitions
  GROUP BY (date_part('year'::text, competitions.date))
  ORDER BY (date_part('year'::text, competitions.date)) DESC
  END_VIEW_YEARS

  add_foreign_key "admin_users", "m3_logins", column: "login_id"
  add_foreign_key "appointments", "events"
  add_foreign_key "appointments", "places"
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
  add_foreign_key "m3_assets", "m3_websites", column: "website_id"
  add_foreign_key "m3_delivery_settings", "m3_websites", column: "website_id"
  add_foreign_key "m3_logins", "m3_websites", column: "website_id"
  add_foreign_key "news_articles", "admin_users"
  add_foreign_key "people", "nations"
  add_foreign_key "person_participations", "group_scores"
  add_foreign_key "person_participations", "people"
  add_foreign_key "person_spellings", "people"
  add_foreign_key "registrations_assessment_participations", "registrations_assessments", column: "assessment_id"
  add_foreign_key "registrations_assessment_participations", "registrations_people", column: "person_id"
  add_foreign_key "registrations_assessment_participations", "registrations_teams", column: "team_id"
  add_foreign_key "registrations_assessments", "registrations_competitions", column: "competition_id"
  add_foreign_key "registrations_competitions", "admin_users"
  add_foreign_key "registrations_competitions_mails", "admin_users"
  add_foreign_key "registrations_competitions_mails", "registrations_competitions", column: "competition_id"
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
  add_foreign_key "team_spellings", "teams"
end
