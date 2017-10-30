class MigrateLogins < ActiveRecord::Migration
  def change
    add_column :admin_users, :login_id, :integer

    ActiveRecord::Base.connection.execute('select * from admin_users').each do |admin_user|
      login = M3::Login::Base.create!(
        name: admin_user['name'],
        email_address: admin_user['email'],
        password_digest: admin_user['encrypted_password'],
        verified_at: admin_user['confirmed_at'],
        website_id: M3::Website.first.id,
      )
      AdminUser.where(id: admin_user['id']).update_all(login_id: login.id)
    end
    change_column_null :admin_users, :login_id, false
    add_index :admin_users, :login_id
    add_foreign_key :admin_users, :m3_logins, column: :login_id

    remove_column :admin_users, :name
    remove_column :admin_users, :email
    remove_column :admin_users, :encrypted_password
    remove_column :admin_users, :confirmed_at
    remove_column :admin_users, :reset_password_token
    remove_column :admin_users, :reset_password_sent_at
    remove_column :admin_users, :remember_created_at
    remove_column :admin_users, :sign_in_count
    remove_column :admin_users, :current_sign_in_at
    remove_column :admin_users, :last_sign_in_at
    remove_column :admin_users, :current_sign_in_ip
    remove_column :admin_users, :last_sign_in_ip
    remove_column :admin_users, :confirmation_token
    remove_column :admin_users, :confirmation_sent_at
    remove_column :admin_users, :unconfirmed_email
    remove_column :admin_users, :failed_attempts
    remove_column :admin_users, :unlock_token
    remove_column :admin_users, :locked_at
  end
end
