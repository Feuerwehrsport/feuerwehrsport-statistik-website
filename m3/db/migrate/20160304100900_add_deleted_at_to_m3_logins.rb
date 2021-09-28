# frozen_string_literal: true

class AddDeletedAtToM3Logins < ActiveRecord::Migration[4.2]
  def change
    add_column :m3_logins, :deleted_at, :datetime
    add_index :m3_logins, :deleted_at
  end
end
