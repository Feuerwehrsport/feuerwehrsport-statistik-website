class CreateSeriesAssessments < ActiveRecord::Migration
  def change
    create_table :series_assessments do |t|
      t.references :round, null: false
      t.string :aggregate_type, null: false
      t.string :discipline, null: false
      t.string :name, null: false, default: ""
      t.string :type, null: false
      t.integer :gender, null: false

      t.timestamps null: false
    end
    add_foreign_key :series_assessments, :series_rounds, column: :round_id
  end
end
