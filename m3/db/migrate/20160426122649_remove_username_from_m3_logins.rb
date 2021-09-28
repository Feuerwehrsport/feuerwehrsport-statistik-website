# frozen_string_literal: true

class RemoveUsernameFromM3Logins < ActiveRecord::Migration[4.2]
  def change
    remove_column :m3_logins, :username
    remove_column :m3_logins, :type
  end
end
