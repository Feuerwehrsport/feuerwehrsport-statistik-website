# frozen_string_literal: true

class DropTags < ActiveRecord::Migration[7.2]
  def change
    drop_table :tags
  end
end
