class CreateSeriesParticipations < ActiveRecord::Migration
  def change
    create_table :series_participations do |t|
      t.references :assessment, null: false
      t.references :cup, null: false
      t.string :type, null: false

      t.references :team, null: true, foreign_key: true
      t.integer :team_number, null: true

      t.references :person, null: true, foreign_key: true

      t.integer :time, null: false
      t.integer :points, null: false, default: 0
      t.integer :rank, null: false

      t.timestamps null: false
    end
    add_foreign_key :series_participations, :series_assessments, column: :assessment_id
    add_foreign_key :series_participations, :series_cups, column: :cup_id
  end
end
