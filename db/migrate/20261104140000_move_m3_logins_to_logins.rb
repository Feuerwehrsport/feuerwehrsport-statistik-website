# frozen_string_literal: true

# login tokens are generated with generates_token_for (signed, not stored) since the m3 engine is gone
class MoveM3LoginsToLogins < ActiveRecord::Migration[8.1]
  def up
    rename_table :m3_logins, :logins

    change_table :logins, bulk: true do |t|
      t.remove_index :verify_token, unique: true
      t.remove_index :password_reset_token, unique: true
      t.remove_index :changed_email_address_token, unique: true
      t.remove :verify_token, :password_reset_token, :password_reset_requested_at,
               :changed_email_address_token, :changed_email_address_requested_at
    end
  end

  def down
    change_table :logins, bulk: true do |t|
      t.string :verify_token
      t.string :password_reset_token
      t.datetime :password_reset_requested_at, precision: nil
      t.string :changed_email_address_token
      t.datetime :changed_email_address_requested_at, precision: nil
    end
    execute 'UPDATE logins SET changed_email_address_token = md5(random()::text || id::text)'
    change_column_null :logins, :changed_email_address_token, false
    add_index :logins, :verify_token, unique: true
    add_index :logins, :password_reset_token, unique: true
    add_index :logins, :changed_email_address_token, unique: true

    rename_table :logins, :m3_logins
  end
end
