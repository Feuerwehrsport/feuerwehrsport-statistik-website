# frozen_string_literal: true

class AllowLoginNameToBeNull < ActiveRecord::Migration[4.2]
  def change
    change_column_null :m3_logins, :name, true
    change_column_default :m3_logins, :name, nil
  end
end
