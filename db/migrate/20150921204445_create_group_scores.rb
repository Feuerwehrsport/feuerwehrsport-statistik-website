class CreateGroupScores < ActiveRecord::Migration
  def change
    create_table :group_scores do |t|
      t.references :team, index: true, foreign_key: true, null: false
      t.integer :team_number, null: false, default: 0
      t.integer :gender, null: false
      t.integer :time, null: false
      t.references :group_score_category, index: true, null: false, foreign_key: true
      t.string :run, null: false

      t.timestamps null: false
    end
  end
end
