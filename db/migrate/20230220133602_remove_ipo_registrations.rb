# frozen_string_literal: true

class RemoveIpoRegistrations < ActiveRecord::Migration[5.2]
  def change
    drop_table :ipo_registrations
  end
end
