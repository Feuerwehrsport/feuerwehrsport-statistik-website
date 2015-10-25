class CreateScores < ActiveRecord::Migration
  def change
    create_table :scores do |t|
      t.references :person, index: true, foreign_key: true, null: false
      t.string :discipline, null: false
      t.references :competition, index: true, foreign_key: true, null: false
      t.integer :time, null: false
      t.references :team, index: true, foreign_key: true
      t.integer :team_number, null: false, default: 0

      t.timestamps null: false
    end
  end
end
