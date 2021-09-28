# frozen_string_literal: true

class RemoveDeletedAtFromM3Logins < ActiveRecord::Migration[4.2]
  def change
    M3::Login::Base.unscoped.where.not(deleted_at: nil).delete_all
    remove_column :m3_logins, :deleted_at, :datetime
  end
end
