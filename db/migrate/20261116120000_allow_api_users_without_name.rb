# frozen_string_literal: true

# anonymous logins need a name and/or an email address
class AllowApiUsersWithoutName < ActiveRecord::Migration[8.1]
  def change
    change_column_null :api_users, :name, true
  end
end
