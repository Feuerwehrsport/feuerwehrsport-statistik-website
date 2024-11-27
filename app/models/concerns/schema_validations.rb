# frozen_string_literal: true

# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.

# generated from version 20241127075044

module SchemaValidations
  extend ActiveSupport::Concern

  included do
    class_attribute :schema_validations_excluded_columns, default: %i[id created_at updated_at type]
    class_attribute :schema_validations_called, default: false

    if defined?(Rails::Railtie) && (Rails.env.development? || Rails.env.test?)
      TracePoint.trace(:end) do |t|
        if t.self.respond_to?(:schema_validations_called) && t.self < ApplicationRecord &&
           !t.self.schema_validations_called
          raise "#{t.self}: schema_validations or skip_schema_validations missing"
        end
      end
    end
  end

  class_methods do
    def schema_validations(exclude: [], schema_table_name: table_name)
      self.schema_validations_called = true
      self.schema_validations_excluded_columns += exclude.map(&:to_sym)
      send("dbv_#{schema_table_name}_validations", enums: defined_enums.keys.map(&:to_sym))
    end

    def skip_schema_validations
      self.schema_validations_called = true
    end


    def dbv_active_record_views_validations(enums: [])
      belongs_to_uniqueness_validations_for([["class_name"]])
      uniqueness_validations_for([["class_name"]])
      validates_with_filter :class_name, {:presence=>{}}
      validates_with_filter :checksum, {:presence=>{}}
      validates_with_filter :options, {:presence=>{}}
      validates_with_filter :refreshed_at, {:date_time_in_db_range=>{}}
    end

    def dbv_admin_users_validations(enums: [])
      belongs_to_presence_validations_for([:login_id])
      validates_with_filter :role, {:presence=>{}}
      validates_with_filter :role, {:length=>{:allow_nil=>true, :maximum=>200}}
      validates_with_filter :created_at, {:presence=>{}}
      validates_with_filter :created_at, {:date_time_in_db_range=>{}}
      validates_with_filter :updated_at, {:presence=>{}}
      validates_with_filter :updated_at, {:date_time_in_db_range=>{}}
      validates_with_filter :login_id, {:presence=>{}}
      validates_with_filter :login_id, {:numericality=>{:allow_nil=>true, :only_integer=>true, :greater_than_or_equal_to=>-2147483648, :less_than=>2147483648}} unless enums.include?(:login_id)
    end

    def dbv_api_users_validations(enums: [])
      validates_with_filter :name, {:presence=>{}}
      validates_with_filter :name, {:length=>{:allow_nil=>true, :maximum=>200}}
      validates_with_filter :email_address, {:length=>{:allow_nil=>true, :maximum=>200}}
      validates_with_filter :ip_address_hash, {:presence=>{}}
      validates_with_filter :ip_address_hash, {:length=>{:allow_nil=>true, :maximum=>200}}
      validates_with_filter :user_agent_hash, {:presence=>{}}
      validates_with_filter :user_agent_hash, {:length=>{:allow_nil=>true, :maximum=>200}}
      validates_with_filter :user_agent_meta, {:length=>{:allow_nil=>true, :maximum=>1000}}
      validates_with_filter :created_at, {:presence=>{}}
      validates_with_filter :created_at, {:date_time_in_db_range=>{}}
      validates_with_filter :updated_at, {:presence=>{}}
      validates_with_filter :updated_at, {:date_time_in_db_range=>{}}
    end

    def dbv_bla_badges_validations(enums: [])
      belongs_to_presence_validations_for([:person_id, :year, :hb_time])
      belongs_to_uniqueness_validations_for([["person_id"]])
      uniqueness_validations_for([["person_id"]])
      validates_with_filter :person_id, {:presence=>{}}
      validates_with_filter :person_id, {:numericality=>{:allow_nil=>true, :only_integer=>true, :greater_than_or_equal_to=>-2147483648, :less_than=>2147483648}} unless enums.include?(:person_id)
      validates_with_filter :status, {:presence=>{}}
      validates_with_filter :status, {:length=>{:allow_nil=>true, :maximum=>200}}
      validates_with_filter :year, {:presence=>{}}
      validates_with_filter :year, {:numericality=>{:allow_nil=>true, :only_integer=>true, :greater_than_or_equal_to=>-2147483648, :less_than=>2147483648}} unless enums.include?(:year)
      validates_with_filter :hl_time, {:numericality=>{:allow_nil=>true, :only_integer=>true, :greater_than_or_equal_to=>-2147483648, :less_than=>2147483648}} unless enums.include?(:hl_time)
      validates_with_filter :hl_score_id, {:numericality=>{:allow_nil=>true, :only_integer=>true, :greater_than_or_equal_to=>-2147483648, :less_than=>2147483648}} unless enums.include?(:hl_score_id)
      validates_with_filter :hb_time, {:presence=>{}}
      validates_with_filter :hb_time, {:numericality=>{:allow_nil=>true, :only_integer=>true, :greater_than_or_equal_to=>-2147483648, :less_than=>2147483648}} unless enums.include?(:hb_time)
      validates_with_filter :hb_score_id, {:numericality=>{:allow_nil=>true, :only_integer=>true, :greater_than_or_equal_to=>-2147483648, :less_than=>2147483648}} unless enums.include?(:hb_score_id)
      validates_with_filter :created_at, {:presence=>{}}
      validates_with_filter :created_at, {:date_time_in_db_range=>{}}
      validates_with_filter :updated_at, {:presence=>{}}
      validates_with_filter :updated_at, {:date_time_in_db_range=>{}}
    end

    def dbv_change_logs_validations(enums: [])
      validates_with_filter :admin_user_id, {:numericality=>{:allow_nil=>true, :only_integer=>true, :greater_than_or_equal_to=>-2147483648, :less_than=>2147483648}} unless enums.include?(:admin_user_id)
      validates_with_filter :api_user_id, {:numericality=>{:allow_nil=>true, :only_integer=>true, :greater_than_or_equal_to=>-2147483648, :less_than=>2147483648}} unless enums.include?(:api_user_id)
      validates_with_filter :model_class, {:presence=>{}}
      validates_with_filter :content, {:presence=>{}}
      validates_with_filter :created_at, {:presence=>{}}
      validates_with_filter :created_at, {:date_time_in_db_range=>{}}
      validates_with_filter :updated_at, {:presence=>{}}
      validates_with_filter :updated_at, {:date_time_in_db_range=>{}}
      validates_with_filter :action, {:presence=>{}}
    end

    def dbv_change_requests_validations(enums: [])
      validates_with_filter :api_user_id, {:numericality=>{:allow_nil=>true, :only_integer=>true, :greater_than_or_equal_to=>-2147483648, :less_than=>2147483648}} unless enums.include?(:api_user_id)
      validates_with_filter :admin_user_id, {:numericality=>{:allow_nil=>true, :only_integer=>true, :greater_than_or_equal_to=>-2147483648, :less_than=>2147483648}} unless enums.include?(:admin_user_id)
      validates_with_filter :content, {:presence=>{}}
      validates_with_filter :done_at, {:date_time_in_db_range=>{}}
      validates_with_filter :created_at, {:presence=>{}}
      validates_with_filter :created_at, {:date_time_in_db_range=>{}}
      validates_with_filter :updated_at, {:presence=>{}}
      validates_with_filter :updated_at, {:date_time_in_db_range=>{}}
    end

    def dbv_competition_files_validations(enums: [])
      belongs_to_presence_validations_for([:competition_id])
      validates_with_filter :competition_id, {:presence=>{}}
      validates_with_filter :competition_id, {:numericality=>{:allow_nil=>true, :only_integer=>true, :greater_than_or_equal_to=>-2147483648, :less_than=>2147483648}} unless enums.include?(:competition_id)
      validates_with_filter :file, {:presence=>{}}
      validates_with_filter :keys_string, {:length=>{:allow_nil=>true, :maximum=>200}}
      validates_with_filter :created_at, {:presence=>{}}
      validates_with_filter :created_at, {:date_time_in_db_range=>{}}
      validates_with_filter :updated_at, {:presence=>{}}
      validates_with_filter :updated_at, {:date_time_in_db_range=>{}}
    end

    def dbv_competitions_validations(enums: [])
      belongs_to_presence_validations_for([:place_id, :event_id, :hl_female, :hl_male, :hb_female, :hb_male, :gs, :fs_female, :fs_male, :la_female, :la_male, :teams_count, :people_count, :year])
      validates_with_filter :name, {:length=>{:allow_nil=>true, :maximum=>200}}
      validates_with_filter :place_id, {:presence=>{}}
      validates_with_filter :place_id, {:numericality=>{:allow_nil=>true, :only_integer=>true, :greater_than_or_equal_to=>-2147483648, :less_than=>2147483648}} unless enums.include?(:place_id)
      validates_with_filter :event_id, {:presence=>{}}
      validates_with_filter :event_id, {:numericality=>{:allow_nil=>true, :only_integer=>true, :greater_than_or_equal_to=>-2147483648, :less_than=>2147483648}} unless enums.include?(:event_id)
      validates_with_filter :score_type_id, {:numericality=>{:allow_nil=>true, :only_integer=>true, :greater_than_or_equal_to=>-2147483648, :less_than=>2147483648}} unless enums.include?(:score_type_id)
      validates_with_filter :date, {:presence=>{}}
      validates_with_filter :date, {:date_in_db_range=>{}}
      validates_with_filter :published_at, {:date_time_in_db_range=>{}}
      validates_with_filter :created_at, {:presence=>{}}
      validates_with_filter :created_at, {:date_time_in_db_range=>{}}
      validates_with_filter :updated_at, {:presence=>{}}
      validates_with_filter :updated_at, {:date_time_in_db_range=>{}}
      validates_with_filter :hl_female, {:presence=>{}}
      validates_with_filter :hl_female, {:numericality=>{:allow_nil=>true, :only_integer=>true, :greater_than_or_equal_to=>-2147483648, :less_than=>2147483648}} unless enums.include?(:hl_female)
      validates_with_filter :hl_male, {:presence=>{}}
      validates_with_filter :hl_male, {:numericality=>{:allow_nil=>true, :only_integer=>true, :greater_than_or_equal_to=>-2147483648, :less_than=>2147483648}} unless enums.include?(:hl_male)
      validates_with_filter :hb_female, {:presence=>{}}
      validates_with_filter :hb_female, {:numericality=>{:allow_nil=>true, :only_integer=>true, :greater_than_or_equal_to=>-2147483648, :less_than=>2147483648}} unless enums.include?(:hb_female)
      validates_with_filter :hb_male, {:presence=>{}}
      validates_with_filter :hb_male, {:numericality=>{:allow_nil=>true, :only_integer=>true, :greater_than_or_equal_to=>-2147483648, :less_than=>2147483648}} unless enums.include?(:hb_male)
      validates_with_filter :gs, {:presence=>{}}
      validates_with_filter :gs, {:numericality=>{:allow_nil=>true, :only_integer=>true, :greater_than_or_equal_to=>-2147483648, :less_than=>2147483648}} unless enums.include?(:gs)
      validates_with_filter :fs_female, {:presence=>{}}
      validates_with_filter :fs_female, {:numericality=>{:allow_nil=>true, :only_integer=>true, :greater_than_or_equal_to=>-2147483648, :less_than=>2147483648}} unless enums.include?(:fs_female)
      validates_with_filter :fs_male, {:presence=>{}}
      validates_with_filter :fs_male, {:numericality=>{:allow_nil=>true, :only_integer=>true, :greater_than_or_equal_to=>-2147483648, :less_than=>2147483648}} unless enums.include?(:fs_male)
      validates_with_filter :la_female, {:presence=>{}}
      validates_with_filter :la_female, {:numericality=>{:allow_nil=>true, :only_integer=>true, :greater_than_or_equal_to=>-2147483648, :less_than=>2147483648}} unless enums.include?(:la_female)
      validates_with_filter :la_male, {:presence=>{}}
      validates_with_filter :la_male, {:numericality=>{:allow_nil=>true, :only_integer=>true, :greater_than_or_equal_to=>-2147483648, :less_than=>2147483648}} unless enums.include?(:la_male)
      validates_with_filter :teams_count, {:presence=>{}}
      validates_with_filter :teams_count, {:numericality=>{:allow_nil=>true, :only_integer=>true, :greater_than_or_equal_to=>-2147483648, :less_than=>2147483648}} unless enums.include?(:teams_count)
      validates_with_filter :people_count, {:presence=>{}}
      validates_with_filter :people_count, {:numericality=>{:allow_nil=>true, :only_integer=>true, :greater_than_or_equal_to=>-2147483648, :less_than=>2147483648}} unless enums.include?(:people_count)
      validates_with_filter :long_name, {:length=>{:allow_nil=>true, :maximum=>200}}
      validates_with_filter :hb_male_for_bla_badge, {:inclusion=>{:in=>[true, false], :message=>:blank}}
      validates_with_filter :hl_male_for_bla_badge, {:inclusion=>{:in=>[true, false], :message=>:blank}}
      validates_with_filter :hb_female_for_bla_badge, {:inclusion=>{:in=>[true, false], :message=>:blank}}
      validates_with_filter :hl_female_for_bla_badge, {:inclusion=>{:in=>[true, false], :message=>:blank}}
      validates_with_filter :year, {:presence=>{}}
      validates_with_filter :year, {:numericality=>{:allow_nil=>true, :only_integer=>true, :greater_than_or_equal_to=>-2147483648, :less_than=>2147483648}} unless enums.include?(:year)
    end

    def dbv_delayed_jobs_validations(enums: [])
      belongs_to_presence_validations_for([:priority, :attempts])
      validates_with_filter :priority, {:presence=>{}}
      validates_with_filter :priority, {:numericality=>{:allow_nil=>true, :only_integer=>true, :greater_than_or_equal_to=>-2147483648, :less_than=>2147483648}} unless enums.include?(:priority)
      validates_with_filter :attempts, {:presence=>{}}
      validates_with_filter :attempts, {:numericality=>{:allow_nil=>true, :only_integer=>true, :greater_than_or_equal_to=>-2147483648, :less_than=>2147483648}} unless enums.include?(:attempts)
      validates_with_filter :handler, {:presence=>{}}
      validates_with_filter :run_at, {:date_time_in_db_range=>{}}
      validates_with_filter :locked_at, {:date_time_in_db_range=>{}}
      validates_with_filter :failed_at, {:date_time_in_db_range=>{}}
      validates_with_filter :created_at, {:date_time_in_db_range=>{}}
      validates_with_filter :updated_at, {:date_time_in_db_range=>{}}
    end

    def dbv_entity_merges_validations(enums: [])
      belongs_to_presence_validations_for([:source_id, :target_id])
      validates_with_filter :source_id, {:presence=>{}}
      validates_with_filter :source_id, {:numericality=>{:allow_nil=>true, :only_integer=>true, :greater_than_or_equal_to=>-2147483648, :less_than=>2147483648}} unless enums.include?(:source_id)
      validates_with_filter :source_type, {:presence=>{}}
      validates_with_filter :target_id, {:presence=>{}}
      validates_with_filter :target_id, {:numericality=>{:allow_nil=>true, :only_integer=>true, :greater_than_or_equal_to=>-2147483648, :less_than=>2147483648}} unless enums.include?(:target_id)
      validates_with_filter :target_type, {:presence=>{}}
      validates_with_filter :created_at, {:presence=>{}}
      validates_with_filter :created_at, {:date_time_in_db_range=>{}}
      validates_with_filter :updated_at, {:presence=>{}}
      validates_with_filter :updated_at, {:date_time_in_db_range=>{}}
    end

    def dbv_events_validations(enums: [])
      validates_with_filter :name, {:presence=>{}}
      validates_with_filter :name, {:length=>{:allow_nil=>true, :maximum=>200}}
      validates_with_filter :created_at, {:presence=>{}}
      validates_with_filter :created_at, {:date_time_in_db_range=>{}}
      validates_with_filter :updated_at, {:presence=>{}}
      validates_with_filter :updated_at, {:date_time_in_db_range=>{}}
    end

    def dbv_federal_states_validations(enums: [])
      validates_with_filter :name, {:presence=>{}}
      validates_with_filter :name, {:length=>{:allow_nil=>true, :maximum=>200}}
      validates_with_filter :shortcut, {:presence=>{}}
      validates_with_filter :shortcut, {:length=>{:allow_nil=>true, :maximum=>10}}
      validates_with_filter :created_at, {:presence=>{}}
      validates_with_filter :created_at, {:date_time_in_db_range=>{}}
      validates_with_filter :updated_at, {:presence=>{}}
      validates_with_filter :updated_at, {:date_time_in_db_range=>{}}
    end

    def dbv_group_score_categories_validations(enums: [])
      belongs_to_presence_validations_for([:group_score_type_id, :competition_id])
      validates_with_filter :group_score_type_id, {:presence=>{}}
      validates_with_filter :group_score_type_id, {:numericality=>{:allow_nil=>true, :only_integer=>true, :greater_than_or_equal_to=>-2147483648, :less_than=>2147483648}} unless enums.include?(:group_score_type_id)
      validates_with_filter :competition_id, {:presence=>{}}
      validates_with_filter :competition_id, {:numericality=>{:allow_nil=>true, :only_integer=>true, :greater_than_or_equal_to=>-2147483648, :less_than=>2147483648}} unless enums.include?(:competition_id)
      validates_with_filter :name, {:presence=>{}}
      validates_with_filter :name, {:length=>{:allow_nil=>true, :maximum=>200}}
      validates_with_filter :created_at, {:presence=>{}}
      validates_with_filter :created_at, {:date_time_in_db_range=>{}}
      validates_with_filter :updated_at, {:presence=>{}}
      validates_with_filter :updated_at, {:date_time_in_db_range=>{}}
    end

    def dbv_group_score_types_validations(enums: [])
      validates_with_filter :discipline, {:presence=>{}}
      validates_with_filter :name, {:presence=>{}}
      validates_with_filter :name, {:length=>{:allow_nil=>true, :maximum=>200}}
      validates_with_filter :regular, {:inclusion=>{:in=>[true, false], :message=>:blank}}
      validates_with_filter :created_at, {:presence=>{}}
      validates_with_filter :created_at, {:date_time_in_db_range=>{}}
      validates_with_filter :updated_at, {:presence=>{}}
      validates_with_filter :updated_at, {:date_time_in_db_range=>{}}
    end

    def dbv_group_scores_validations(enums: [])
      belongs_to_presence_validations_for([:team_id, :team_number, :gender, :time, :group_score_category_id])
      validates_with_filter :team_id, {:presence=>{}}
      validates_with_filter :team_id, {:numericality=>{:allow_nil=>true, :only_integer=>true, :greater_than_or_equal_to=>-2147483648, :less_than=>2147483648}} unless enums.include?(:team_id)
      validates_with_filter :team_number, {:presence=>{}}
      validates_with_filter :team_number, {:numericality=>{:allow_nil=>true, :only_integer=>true, :greater_than_or_equal_to=>-2147483648, :less_than=>2147483648}} unless enums.include?(:team_number)
      validates_with_filter :gender, {:presence=>{}}
      validates_with_filter :gender, {:numericality=>{:allow_nil=>true, :only_integer=>true, :greater_than_or_equal_to=>-2147483648, :less_than=>2147483648}} unless enums.include?(:gender)
      validates_with_filter :time, {:presence=>{}}
      validates_with_filter :time, {:numericality=>{:allow_nil=>true, :only_integer=>true, :greater_than_or_equal_to=>-2147483648, :less_than=>2147483648}} unless enums.include?(:time)
      validates_with_filter :group_score_category_id, {:presence=>{}}
      validates_with_filter :group_score_category_id, {:numericality=>{:allow_nil=>true, :only_integer=>true, :greater_than_or_equal_to=>-2147483648, :less_than=>2147483648}} unless enums.include?(:group_score_category_id)
      validates_with_filter :run, {:length=>{:allow_nil=>true, :maximum=>1}}
      validates_with_filter :created_at, {:presence=>{}}
      validates_with_filter :created_at, {:date_time_in_db_range=>{}}
      validates_with_filter :updated_at, {:presence=>{}}
      validates_with_filter :updated_at, {:date_time_in_db_range=>{}}
    end

    def dbv_import_request_files_validations(enums: [])
      belongs_to_presence_validations_for([:import_request_id])
      validates_with_filter :import_request_id, {:presence=>{}}
      validates_with_filter :import_request_id, {:numericality=>{:allow_nil=>true, :only_integer=>true, :greater_than_or_equal_to=>-2147483648, :less_than=>2147483648}} unless enums.include?(:import_request_id)
      validates_with_filter :file, {:presence=>{}}
      validates_with_filter :created_at, {:presence=>{}}
      validates_with_filter :created_at, {:date_time_in_db_range=>{}}
      validates_with_filter :updated_at, {:presence=>{}}
      validates_with_filter :updated_at, {:date_time_in_db_range=>{}}
      validates_with_filter :transfered, {:inclusion=>{:in=>[true, false], :message=>:blank}}
    end

    def dbv_import_requests_validations(enums: [])
      validates_with_filter :date, {:date_in_db_range=>{}}
      validates_with_filter :place_id, {:numericality=>{:allow_nil=>true, :only_integer=>true, :greater_than_or_equal_to=>-2147483648, :less_than=>2147483648}} unless enums.include?(:place_id)
      validates_with_filter :event_id, {:numericality=>{:allow_nil=>true, :only_integer=>true, :greater_than_or_equal_to=>-2147483648, :less_than=>2147483648}} unless enums.include?(:event_id)
      validates_with_filter :admin_user_id, {:numericality=>{:allow_nil=>true, :only_integer=>true, :greater_than_or_equal_to=>-2147483648, :less_than=>2147483648}} unless enums.include?(:admin_user_id)
      validates_with_filter :edit_user_id, {:numericality=>{:allow_nil=>true, :only_integer=>true, :greater_than_or_equal_to=>-2147483648, :less_than=>2147483648}} unless enums.include?(:edit_user_id)
      validates_with_filter :edited_at, {:date_time_in_db_range=>{}}
      validates_with_filter :finished_at, {:date_time_in_db_range=>{}}
      validates_with_filter :created_at, {:presence=>{}}
      validates_with_filter :created_at, {:date_time_in_db_range=>{}}
      validates_with_filter :updated_at, {:presence=>{}}
      validates_with_filter :updated_at, {:date_time_in_db_range=>{}}
    end

    def dbv_links_validations(enums: [])
      belongs_to_presence_validations_for([:linkable_id])
      validates_with_filter :label, {:presence=>{}}
      validates_with_filter :linkable_id, {:presence=>{}}
      validates_with_filter :linkable_id, {:numericality=>{:allow_nil=>true, :only_integer=>true, :greater_than_or_equal_to=>-2147483648, :less_than=>2147483648}} unless enums.include?(:linkable_id)
      validates_with_filter :linkable_type, {:presence=>{}}
      validates_with_filter :url, {:presence=>{}}
      validates_with_filter :created_at, {:presence=>{}}
      validates_with_filter :created_at, {:date_time_in_db_range=>{}}
      validates_with_filter :updated_at, {:presence=>{}}
      validates_with_filter :updated_at, {:date_time_in_db_range=>{}}
    end

    def dbv_m3_assets_validations(enums: [])
      validates_with_filter :name, {:length=>{:allow_nil=>true, :maximum=>200}}
      validates_with_filter :image, {:inclusion=>{:in=>[true, false], :message=>:blank}}
      validates_with_filter :created_at, {:presence=>{}}
      validates_with_filter :created_at, {:date_time_in_db_range=>{}}
      validates_with_filter :updated_at, {:presence=>{}}
      validates_with_filter :updated_at, {:date_time_in_db_range=>{}}
    end

    def dbv_m3_logins_validations(enums: [])
      belongs_to_uniqueness_validations_for([["changed_email_address_token"], ["password_reset_token"], ["verify_token"]])
      uniqueness_validations_for([["changed_email_address_token"], ["password_reset_token"], ["verify_token"]])
      validates_with_filter :email_address, {:presence=>{}}
      validates_with_filter :verified_at, {:date_time_in_db_range=>{}}
      validates_with_filter :created_at, {:presence=>{}}
      validates_with_filter :created_at, {:date_time_in_db_range=>{}}
      validates_with_filter :updated_at, {:presence=>{}}
      validates_with_filter :updated_at, {:date_time_in_db_range=>{}}
      validates_with_filter :password_reset_requested_at, {:date_time_in_db_range=>{}}
      validates_with_filter :expired_at, {:date_time_in_db_range=>{}}
      validates_with_filter :changed_email_address_token, {:presence=>{}}
      validates_with_filter :changed_email_address_requested_at, {:date_time_in_db_range=>{}}
    end

    def dbv_nations_validations(enums: [])
      validates_with_filter :name, {:presence=>{}}
      validates_with_filter :name, {:length=>{:allow_nil=>true, :maximum=>200}}
      validates_with_filter :iso, {:presence=>{}}
      validates_with_filter :iso, {:length=>{:allow_nil=>true, :maximum=>10}}
      validates_with_filter :created_at, {:presence=>{}}
      validates_with_filter :created_at, {:date_time_in_db_range=>{}}
      validates_with_filter :updated_at, {:presence=>{}}
      validates_with_filter :updated_at, {:date_time_in_db_range=>{}}
    end

    def dbv_people_validations(enums: [])
      belongs_to_presence_validations_for([:gender, :nation_id, :hb_count, :hl_count, :la_count, :fs_count, :gs_count])
      validates_with_filter :last_name, {:presence=>{}}
      validates_with_filter :last_name, {:length=>{:allow_nil=>true, :maximum=>200}}
      validates_with_filter :first_name, {:presence=>{}}
      validates_with_filter :first_name, {:length=>{:allow_nil=>true, :maximum=>200}}
      validates_with_filter :gender, {:presence=>{}}
      validates_with_filter :gender, {:numericality=>{:allow_nil=>true, :only_integer=>true, :greater_than_or_equal_to=>-2147483648, :less_than=>2147483648}} unless enums.include?(:gender)
      validates_with_filter :nation_id, {:presence=>{}}
      validates_with_filter :nation_id, {:numericality=>{:allow_nil=>true, :only_integer=>true, :greater_than_or_equal_to=>-2147483648, :less_than=>2147483648}} unless enums.include?(:nation_id)
      validates_with_filter :created_at, {:presence=>{}}
      validates_with_filter :created_at, {:date_time_in_db_range=>{}}
      validates_with_filter :updated_at, {:presence=>{}}
      validates_with_filter :updated_at, {:date_time_in_db_range=>{}}
      validates_with_filter :hb_count, {:presence=>{}}
      validates_with_filter :hb_count, {:numericality=>{:allow_nil=>true, :only_integer=>true, :greater_than_or_equal_to=>-2147483648, :less_than=>2147483648}} unless enums.include?(:hb_count)
      validates_with_filter :hl_count, {:presence=>{}}
      validates_with_filter :hl_count, {:numericality=>{:allow_nil=>true, :only_integer=>true, :greater_than_or_equal_to=>-2147483648, :less_than=>2147483648}} unless enums.include?(:hl_count)
      validates_with_filter :la_count, {:presence=>{}}
      validates_with_filter :la_count, {:numericality=>{:allow_nil=>true, :only_integer=>true, :greater_than_or_equal_to=>-2147483648, :less_than=>2147483648}} unless enums.include?(:la_count)
      validates_with_filter :fs_count, {:presence=>{}}
      validates_with_filter :fs_count, {:numericality=>{:allow_nil=>true, :only_integer=>true, :greater_than_or_equal_to=>-2147483648, :less_than=>2147483648}} unless enums.include?(:fs_count)
      validates_with_filter :gs_count, {:presence=>{}}
      validates_with_filter :gs_count, {:numericality=>{:allow_nil=>true, :only_integer=>true, :greater_than_or_equal_to=>-2147483648, :less_than=>2147483648}} unless enums.include?(:gs_count)
      validates_with_filter :ignore_bla_untill_year, {:numericality=>{:allow_nil=>true, :only_integer=>true, :greater_than_or_equal_to=>-2147483648, :less_than=>2147483648}} unless enums.include?(:ignore_bla_untill_year)
    end

    def dbv_person_participations_validations(enums: [])
      belongs_to_presence_validations_for([:person_id, :group_score_id, :position])
      validates_with_filter :person_id, {:presence=>{}}
      validates_with_filter :person_id, {:numericality=>{:allow_nil=>true, :only_integer=>true, :greater_than_or_equal_to=>-2147483648, :less_than=>2147483648}} unless enums.include?(:person_id)
      validates_with_filter :group_score_id, {:presence=>{}}
      validates_with_filter :group_score_id, {:numericality=>{:allow_nil=>true, :only_integer=>true, :greater_than_or_equal_to=>-2147483648, :less_than=>2147483648}} unless enums.include?(:group_score_id)
      validates_with_filter :position, {:presence=>{}}
      validates_with_filter :position, {:numericality=>{:allow_nil=>true, :only_integer=>true, :greater_than_or_equal_to=>-2147483648, :less_than=>2147483648}} unless enums.include?(:position)
      validates_with_filter :created_at, {:presence=>{}}
      validates_with_filter :created_at, {:date_time_in_db_range=>{}}
      validates_with_filter :updated_at, {:presence=>{}}
      validates_with_filter :updated_at, {:date_time_in_db_range=>{}}
    end

    def dbv_person_spellings_validations(enums: [])
      belongs_to_presence_validations_for([:person_id, :gender])
      validates_with_filter :person_id, {:presence=>{}}
      validates_with_filter :person_id, {:numericality=>{:allow_nil=>true, :only_integer=>true, :greater_than_or_equal_to=>-2147483648, :less_than=>2147483648}} unless enums.include?(:person_id)
      validates_with_filter :last_name, {:presence=>{}}
      validates_with_filter :last_name, {:length=>{:allow_nil=>true, :maximum=>200}}
      validates_with_filter :first_name, {:presence=>{}}
      validates_with_filter :first_name, {:length=>{:allow_nil=>true, :maximum=>200}}
      validates_with_filter :gender, {:presence=>{}}
      validates_with_filter :gender, {:numericality=>{:allow_nil=>true, :only_integer=>true, :greater_than_or_equal_to=>-2147483648, :less_than=>2147483648}} unless enums.include?(:gender)
      validates_with_filter :official, {:inclusion=>{:in=>[true, false], :message=>:blank}}
      validates_with_filter :created_at, {:presence=>{}}
      validates_with_filter :created_at, {:date_time_in_db_range=>{}}
      validates_with_filter :updated_at, {:presence=>{}}
      validates_with_filter :updated_at, {:date_time_in_db_range=>{}}
    end

    def dbv_places_validations(enums: [])
      validates_with_filter :name, {:presence=>{}}
      validates_with_filter :name, {:length=>{:allow_nil=>true, :maximum=>200}}
      validates_with_filter :latitude, {:numericality=>{:allow_nil=>true, :greater_than=>-100000, :less_than=>100000}}
      validates_with_filter :longitude, {:numericality=>{:allow_nil=>true, :greater_than=>-100000, :less_than=>100000}}
      validates_with_filter :created_at, {:presence=>{}}
      validates_with_filter :created_at, {:date_time_in_db_range=>{}}
      validates_with_filter :updated_at, {:presence=>{}}
      validates_with_filter :updated_at, {:date_time_in_db_range=>{}}
    end

    def dbv_score_types_validations(enums: [])
      belongs_to_presence_validations_for([:people, :run, :score])
      validates_with_filter :people, {:presence=>{}}
      validates_with_filter :people, {:numericality=>{:allow_nil=>true, :only_integer=>true, :greater_than_or_equal_to=>-2147483648, :less_than=>2147483648}} unless enums.include?(:people)
      validates_with_filter :run, {:presence=>{}}
      validates_with_filter :run, {:numericality=>{:allow_nil=>true, :only_integer=>true, :greater_than_or_equal_to=>-2147483648, :less_than=>2147483648}} unless enums.include?(:run)
      validates_with_filter :score, {:presence=>{}}
      validates_with_filter :score, {:numericality=>{:allow_nil=>true, :only_integer=>true, :greater_than_or_equal_to=>-2147483648, :less_than=>2147483648}} unless enums.include?(:score)
      validates_with_filter :created_at, {:presence=>{}}
      validates_with_filter :created_at, {:date_time_in_db_range=>{}}
      validates_with_filter :updated_at, {:presence=>{}}
      validates_with_filter :updated_at, {:date_time_in_db_range=>{}}
    end

    def dbv_scores_validations(enums: [])
      belongs_to_presence_validations_for([:person_id, :competition_id, :time, :team_number, :single_discipline_id])
      validates_with_filter :person_id, {:presence=>{}}
      validates_with_filter :person_id, {:numericality=>{:allow_nil=>true, :only_integer=>true, :greater_than_or_equal_to=>-2147483648, :less_than=>2147483648}} unless enums.include?(:person_id)
      validates_with_filter :competition_id, {:presence=>{}}
      validates_with_filter :competition_id, {:numericality=>{:allow_nil=>true, :only_integer=>true, :greater_than_or_equal_to=>-2147483648, :less_than=>2147483648}} unless enums.include?(:competition_id)
      validates_with_filter :time, {:presence=>{}}
      validates_with_filter :time, {:numericality=>{:allow_nil=>true, :only_integer=>true, :greater_than_or_equal_to=>-2147483648, :less_than=>2147483648}} unless enums.include?(:time)
      validates_with_filter :team_id, {:numericality=>{:allow_nil=>true, :only_integer=>true, :greater_than_or_equal_to=>-2147483648, :less_than=>2147483648}} unless enums.include?(:team_id)
      validates_with_filter :team_number, {:presence=>{}}
      validates_with_filter :team_number, {:numericality=>{:allow_nil=>true, :only_integer=>true, :greater_than_or_equal_to=>-2147483648, :less_than=>2147483648}} unless enums.include?(:team_number)
      validates_with_filter :created_at, {:presence=>{}}
      validates_with_filter :created_at, {:date_time_in_db_range=>{}}
      validates_with_filter :updated_at, {:presence=>{}}
      validates_with_filter :updated_at, {:date_time_in_db_range=>{}}
      validates_with_filter :single_discipline_id, {:presence=>{}}
      validates_with_filter :single_discipline_id, {:numericality=>{:allow_nil=>true}} unless enums.include?(:single_discipline_id)
    end

    def dbv_series_assessments_validations(enums: [])
      belongs_to_presence_validations_for([:round_id, :gender])
      validates_with_filter :round_id, {:presence=>{}}
      validates_with_filter :round_id, {:numericality=>{:allow_nil=>true, :only_integer=>true, :greater_than_or_equal_to=>-2147483648, :less_than=>2147483648}} unless enums.include?(:round_id)
      validates_with_filter :discipline, {:presence=>{}}
      validates_with_filter :discipline, {:length=>{:allow_nil=>true, :maximum=>3}}
      validates_with_filter :name, {:length=>{:allow_nil=>true, :maximum=>200}}
      validates_with_filter :type, {:presence=>{}}
      validates_with_filter :type, {:length=>{:allow_nil=>true, :maximum=>200}}
      validates_with_filter :gender, {:presence=>{}}
      validates_with_filter :gender, {:numericality=>{:allow_nil=>true, :only_integer=>true, :greater_than_or_equal_to=>-2147483648, :less_than=>2147483648}} unless enums.include?(:gender)
      validates_with_filter :created_at, {:presence=>{}}
      validates_with_filter :created_at, {:date_time_in_db_range=>{}}
      validates_with_filter :updated_at, {:presence=>{}}
      validates_with_filter :updated_at, {:date_time_in_db_range=>{}}
    end

    def dbv_series_cups_validations(enums: [])
      belongs_to_presence_validations_for([:round_id, :competition_id])
      validates_with_filter :round_id, {:presence=>{}}
      validates_with_filter :round_id, {:numericality=>{:allow_nil=>true, :only_integer=>true, :greater_than_or_equal_to=>-2147483648, :less_than=>2147483648}} unless enums.include?(:round_id)
      validates_with_filter :competition_id, {:presence=>{}}
      validates_with_filter :competition_id, {:numericality=>{:allow_nil=>true, :only_integer=>true, :greater_than_or_equal_to=>-2147483648, :less_than=>2147483648}} unless enums.include?(:competition_id)
      validates_with_filter :created_at, {:presence=>{}}
      validates_with_filter :created_at, {:date_time_in_db_range=>{}}
      validates_with_filter :updated_at, {:presence=>{}}
      validates_with_filter :updated_at, {:date_time_in_db_range=>{}}
    end

    def dbv_series_kinds_validations(enums: [])
      belongs_to_uniqueness_validations_for([["slug"]])
      uniqueness_validations_for([["slug"]])
      validates_with_filter :name, {:presence=>{}}
      validates_with_filter :slug, {:presence=>{}}
      validates_with_filter :created_at, {:presence=>{}}
      validates_with_filter :created_at, {:date_time_in_db_range=>{}}
      validates_with_filter :updated_at, {:presence=>{}}
      validates_with_filter :updated_at, {:date_time_in_db_range=>{}}
    end

    def dbv_series_participations_validations(enums: [])
      belongs_to_presence_validations_for([:assessment_id, :cup_id, :time, :points, :rank])
      validates_with_filter :assessment_id, {:presence=>{}}
      validates_with_filter :assessment_id, {:numericality=>{:allow_nil=>true, :only_integer=>true, :greater_than_or_equal_to=>-2147483648, :less_than=>2147483648}} unless enums.include?(:assessment_id)
      validates_with_filter :cup_id, {:presence=>{}}
      validates_with_filter :cup_id, {:numericality=>{:allow_nil=>true, :only_integer=>true, :greater_than_or_equal_to=>-2147483648, :less_than=>2147483648}} unless enums.include?(:cup_id)
      validates_with_filter :type, {:presence=>{}}
      validates_with_filter :team_id, {:numericality=>{:allow_nil=>true, :only_integer=>true, :greater_than_or_equal_to=>-2147483648, :less_than=>2147483648}} unless enums.include?(:team_id)
      validates_with_filter :team_number, {:numericality=>{:allow_nil=>true, :only_integer=>true, :greater_than_or_equal_to=>-2147483648, :less_than=>2147483648}} unless enums.include?(:team_number)
      validates_with_filter :person_id, {:numericality=>{:allow_nil=>true, :only_integer=>true, :greater_than_or_equal_to=>-2147483648, :less_than=>2147483648}} unless enums.include?(:person_id)
      validates_with_filter :time, {:presence=>{}}
      validates_with_filter :time, {:numericality=>{:allow_nil=>true, :only_integer=>true, :greater_than_or_equal_to=>-2147483648, :less_than=>2147483648}} unless enums.include?(:time)
      validates_with_filter :points, {:presence=>{}}
      validates_with_filter :points, {:numericality=>{:allow_nil=>true, :only_integer=>true, :greater_than_or_equal_to=>-2147483648, :less_than=>2147483648}} unless enums.include?(:points)
      validates_with_filter :rank, {:presence=>{}}
      validates_with_filter :rank, {:numericality=>{:allow_nil=>true, :only_integer=>true, :greater_than_or_equal_to=>-2147483648, :less_than=>2147483648}} unless enums.include?(:rank)
      validates_with_filter :created_at, {:presence=>{}}
      validates_with_filter :created_at, {:date_time_in_db_range=>{}}
      validates_with_filter :updated_at, {:presence=>{}}
      validates_with_filter :updated_at, {:date_time_in_db_range=>{}}
    end

    def dbv_series_rounds_validations(enums: [])
      belongs_to_presence_validations_for([:year, :full_cup_count])
      validates_with_filter :year, {:presence=>{}}
      validates_with_filter :year, {:numericality=>{:allow_nil=>true, :only_integer=>true, :greater_than_or_equal_to=>-2147483648, :less_than=>2147483648}} unless enums.include?(:year)
      validates_with_filter :aggregate_type, {:presence=>{}}
      validates_with_filter :created_at, {:presence=>{}}
      validates_with_filter :created_at, {:date_time_in_db_range=>{}}
      validates_with_filter :updated_at, {:presence=>{}}
      validates_with_filter :updated_at, {:date_time_in_db_range=>{}}
      validates_with_filter :official, {:inclusion=>{:in=>[true, false], :message=>:blank}}
      validates_with_filter :full_cup_count, {:presence=>{}}
      validates_with_filter :full_cup_count, {:numericality=>{:allow_nil=>true, :only_integer=>true, :greater_than_or_equal_to=>-2147483648, :less_than=>2147483648}} unless enums.include?(:full_cup_count)
      validates_with_filter :kind_id, {:numericality=>{:allow_nil=>true}} unless enums.include?(:kind_id)
    end

    def dbv_single_disciplines_validations(enums: [])
      validates_with_filter :key, {:presence=>{}}
      validates_with_filter :key, {:length=>{:allow_nil=>true, :maximum=>2}}
      validates_with_filter :short_name, {:presence=>{}}
      validates_with_filter :short_name, {:length=>{:allow_nil=>true, :maximum=>100}}
      validates_with_filter :name, {:presence=>{}}
      validates_with_filter :name, {:length=>{:allow_nil=>true, :maximum=>200}}
      validates_with_filter :description, {:presence=>{}}
      validates_with_filter :default_for_male, {:inclusion=>{:in=>[true, false], :message=>:blank}}
      validates_with_filter :default_for_female, {:inclusion=>{:in=>[true, false], :message=>:blank}}
      validates_with_filter :created_at, {:presence=>{}}
      validates_with_filter :created_at, {:date_time_in_db_range=>{}}
      validates_with_filter :updated_at, {:presence=>{}}
      validates_with_filter :updated_at, {:date_time_in_db_range=>{}}
    end

    def dbv_tags_validations(enums: [])
      belongs_to_presence_validations_for([:taggable_id])
      validates_with_filter :taggable_id, {:presence=>{}}
      validates_with_filter :taggable_id, {:numericality=>{:allow_nil=>true, :only_integer=>true, :greater_than_or_equal_to=>-2147483648, :less_than=>2147483648}} unless enums.include?(:taggable_id)
      validates_with_filter :taggable_type, {:presence=>{}}
      validates_with_filter :name, {:presence=>{}}
      validates_with_filter :created_at, {:presence=>{}}
      validates_with_filter :created_at, {:date_time_in_db_range=>{}}
      validates_with_filter :updated_at, {:presence=>{}}
      validates_with_filter :updated_at, {:date_time_in_db_range=>{}}
    end

    def dbv_team_spellings_validations(enums: [])
      belongs_to_presence_validations_for([:team_id])
      validates_with_filter :team_id, {:presence=>{}}
      validates_with_filter :team_id, {:numericality=>{:allow_nil=>true, :only_integer=>true, :greater_than_or_equal_to=>-2147483648, :less_than=>2147483648}} unless enums.include?(:team_id)
      validates_with_filter :name, {:presence=>{}}
      validates_with_filter :name, {:length=>{:allow_nil=>true, :maximum=>200}}
      validates_with_filter :shortcut, {:presence=>{}}
      validates_with_filter :shortcut, {:length=>{:allow_nil=>true, :maximum=>200}}
      validates_with_filter :created_at, {:presence=>{}}
      validates_with_filter :created_at, {:date_time_in_db_range=>{}}
      validates_with_filter :updated_at, {:presence=>{}}
      validates_with_filter :updated_at, {:date_time_in_db_range=>{}}
    end

    def dbv_teams_validations(enums: [])
      belongs_to_presence_validations_for([:status, :members_count, :competitions_count])
      validates_with_filter :name, {:presence=>{}}
      validates_with_filter :name, {:length=>{:allow_nil=>true, :maximum=>200}}
      validates_with_filter :shortcut, {:presence=>{}}
      validates_with_filter :shortcut, {:length=>{:allow_nil=>true, :maximum=>200}}
      validates_with_filter :status, {:presence=>{}}
      validates_with_filter :status, {:numericality=>{:allow_nil=>true, :only_integer=>true, :greater_than_or_equal_to=>-2147483648, :less_than=>2147483648}} unless enums.include?(:status)
      validates_with_filter :latitude, {:numericality=>{:allow_nil=>true, :greater_than=>-100000, :less_than=>100000}}
      validates_with_filter :longitude, {:numericality=>{:allow_nil=>true, :greater_than=>-100000, :less_than=>100000}}
      validates_with_filter :state, {:length=>{:allow_nil=>true, :maximum=>200}}
      validates_with_filter :created_at, {:presence=>{}}
      validates_with_filter :created_at, {:date_time_in_db_range=>{}}
      validates_with_filter :updated_at, {:presence=>{}}
      validates_with_filter :updated_at, {:date_time_in_db_range=>{}}
      validates_with_filter :checked_at, {:date_time_in_db_range=>{}}
      validates_with_filter :members_count, {:presence=>{}}
      validates_with_filter :members_count, {:numericality=>{:allow_nil=>true, :only_integer=>true, :greater_than_or_equal_to=>-2147483648, :less_than=>2147483648}} unless enums.include?(:members_count)
      validates_with_filter :competitions_count, {:presence=>{}}
      validates_with_filter :competitions_count, {:numericality=>{:allow_nil=>true, :only_integer=>true, :greater_than_or_equal_to=>-2147483648, :less_than=>2147483648}} unless enums.include?(:competitions_count)
    end


    def validates_with_filter(attribute, options)
      return if attribute.to_sym.in?(schema_validations_excluded_columns)

      validates attribute, options
    end

    def belongs_to_presence_validations_for(not_null_columns)
      reflect_on_all_associations(:belongs_to).each do |association|
        if not_null_columns.include?(association.foreign_key.to_sym)
          validates association.name, presence: true
          schema_validations_excluded_columns.push(association.foreign_key.to_sym)
        end
      end
    end

    def bad_uniqueness_validations_for(unique_indexes)
      unique_indexes.each do |names|
        names.each do |name|
          next if name.to_sym.in?(schema_validations_excluded_columns)

          raise "Unique index with where clause is outside the scope of this gem.\n\n" \
                "You can exclude this column: `schema_validations exclude: [:#{name}]`"
        end
      end
    end

    def belongs_to_uniqueness_validations_for(unique_indexes)
      reflect_on_all_associations(:belongs_to).each do |association|
        dbv_uniqueness_validations_for(unique_indexes, foreign_key: association.foreign_key.to_s,
                                                       column: association.name)
      end
    end

    def uniqueness_validations_for(unique_indexes)
      unique_indexes.each do |names|
        names.each do |name|
          dbv_uniqueness_validations_for(unique_indexes, foreign_key: name, column: name)
        end
      end
    end

    def dbv_uniqueness_validations_for(unique_indexes, foreign_key:, column:)
      unique_indexes.each do |names|
        next unless foreign_key.in?(names)
        next if column.to_sym.in?(schema_validations_excluded_columns)

        scope = (names - [foreign_key]).map(&:to_sym)
        options = { allow_nil: true }
        options[:scope] = scope if scope.any?
        options[:if] = (proc do |record|
          if scope.all? { |scope_sym| record.public_send(:"#{scope_sym}?") }
            record.public_send(:"#{foreign_key}_changed?")
          else
            false
          end
        end)

        validates column, uniqueness: options
      end
    end
  end

  class DateTimeInDbRangeValidator < ActiveModel::EachValidator
    def validate_each(record, attr_name, value)
      return if value.nil?
      return unless value.is_a?(DateTime) || value.is_a?(Time)
      return if value.year.between?(-4711, 294275) # see https://www.postgresql.org/docs/9.3/datatype-datetime.html

      record.errors.add(attr_name, :invalid, options)
    end
  end

  class DateInDbRangeValidator < ActiveModel::EachValidator
    def validate_each(record, attr_name, value)
      return if value.nil?
      return unless value.is_a?(Date)
      return if value.year.between?(-4711, 5874896) # see https://www.postgresql.org/docs/9.3/datatype-datetime.html

      record.errors.add(attr_name, :invalid, options)
    end
  end
end
