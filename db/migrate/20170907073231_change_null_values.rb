class ChangeNullValues < ActiveRecord::Migration
  def change
    change_column_null :news, :admin_user_id, false
    change_column_null :news, :published_at, false
    change_column :news, :title, :string, null: false, limit: 200
    change_column :news, :content, :text, null: false

    change_column :admin_users, :role, :string, default: 'user', null: false, limit: 200

    change_column :api_users, :name, :string, limit: 200, null: false
    change_column :api_users, :email_address, :string, limit: 200
    change_column :api_users, :ip_address_hash, :string, limit: 200, null: false
    change_column :api_users, :user_agent_hash, :string, limit: 200, null: false
    change_column :api_users, :user_agent_meta, :string, limit: 1000

    change_column :appointments, :name, :string,         null: false, limit: 200
    change_column :appointments, :disciplines, :string,  default: '', null: false, limit: 200

    CompetitionFile.all.each do |file|
      CompetitionFile.where(id: file.id).update_all(keys_string: file.keys.uniq.join(','))
    end
    change_column :competition_files, :competition_id, :integer, null: false
    change_column :competition_files, :file, :string, null: false
    change_column :competition_files, :keys_string, :string, limit: 200

    change_column_null :change_requests, :files_data, true

    change_column :group_score_categories, :name, :string, null: false, limit: 200

    change_column :group_scores, :run, :string, null: true, limit: 1

    change_column :people, :last_name, :string,  null: false, limit: 200
    change_column :people, :first_name, :string, null: false, limit: 200

    change_column :competitions, :name, :string, limit: 200
    change_column :competitions, :hint_content, :text

    change_column :events, :name, :string, null: false, limit: 200

    change_column :federal_states, :name, :string,       null: false, limit: 200
    change_column :federal_states, :shortcut, :string,   null: false, limit: 10

    change_column :group_score_types, :name, :string, null: false, limit: 200

    change_column :links, :label, :string, null: false
    change_column :links, :linkable_id, :integer, null: false
    change_column :links, :linkable_type, :string, null: false
    change_column :links, :url, :text, null: false

    change_column :nations, :name, :string,       null: false, limit: 200
    change_column :nations, :iso, :string,        null: false, limit: 10

    change_column :person_spellings, :last_name, :string,  null: false, limit: 200
    change_column :person_spellings, :first_name, :string, null: false, limit: 200

    change_column :places, :name, :string, null: false, limit: 200

    change_column :series_assessments, :discipline, :string, null: false, limit: 3
    change_column :series_assessments, :name, :string,       default: '', null: false, limit: 200
    change_column :series_assessments, :type, :string,       null: false, limit: 200

    change_column :team_spellings, :name, :string,       null: false, limit: 200
    change_column :team_spellings, :shortcut, :string,   null: false, limit: 200

    change_column :teams, :name, :string,       null: false, limit: 200
    change_column :teams, :shortcut, :string,   null: false, limit: 200
    change_column :teams, :state, :string, limit: 200
  end
end
