# frozen_string_literal: true

class AddChangedEMailAddressToM3Login < ActiveRecord::Migration[4.2]
  def change
    add_column :m3_logins, :changed_email_address, :string
    add_column :m3_logins, :changed_email_address_token, :string
    add_column :m3_logins, :changed_email_address_requested_at, :datetime
    if M3::Login::Base.respond_to?(:with_deleted)
      M3::Login::Base.with_deleted.update_all('changed_email_address_token = MD5(RANDOM()::TEXT)')
    end
    change_column_null :m3_logins, :changed_email_address_token, false
    add_index :m3_logins, :changed_email_address_token, unique: true
  end
end
