# frozen_string_literal: true

class AddExpiredAtToM3Logins < ActiveRecord::Migration[4.2]
  def change
    add_column :m3_logins, :expired_at, :datetime
  end
end
