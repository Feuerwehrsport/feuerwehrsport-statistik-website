# frozen_string_literal: true

class AddPasswordResetTokenToM3Logins < ActiveRecord::Migration[4.2]
  def change
    add_column :m3_logins, :password_reset_requested_at, :datetime
    add_column :m3_logins, :password_reset_token, :string
    add_index :m3_logins, :password_reset_token, unique: true
  end
end
