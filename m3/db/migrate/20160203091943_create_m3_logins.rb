# frozen_string_literal: true

class CreateM3Logins < ActiveRecord::Migration[4.2]
  def change
    create_table :m3_logins do |t|
      t.string :type, null: false
      t.string :name, null: false, default: ''
      t.string :username, null: false
      t.string :email_address, null: false
      t.string :password_digest

      t.datetime :verified_at
      t.string :verify_token

      t.references :website, index: true, null: false
      t.timestamps null: false
    end
    add_foreign_key :m3_logins, :m3_websites, column: :website_id
    add_index :m3_logins, :verify_token, unique: true
  end
end
