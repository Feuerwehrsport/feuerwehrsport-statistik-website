# frozen_string_literal: true

class AddUniqueIndexToM3Website < ActiveRecord::Migration[4.2]
  def change
    add_index :m3_websites, :key, unique: true
  end
end
