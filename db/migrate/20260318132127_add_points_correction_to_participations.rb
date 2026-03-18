# frozen_string_literal: true

class AddPointsCorrectionToParticipations < ActiveRecord::Migration[7.2]
  def change
    change_table :series_team_participations, bulk: true do |t|
      t.integer :points_correction, default: nil, null: true
      t.string :points_correction_hint, null: true, limit: 200
    end
    change_table :series_person_participations, bulk: true do |t|
      t.integer :points_correction, default: nil, null: true
      t.string :points_correction_hint, null: true, limit: 200
    end
  end
end
