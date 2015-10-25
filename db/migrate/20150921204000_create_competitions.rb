class CreateCompetitions < ActiveRecord::Migration
  def change
    create_table :competitions do |t|
      t.string :name, default: "", null: false
      t.references :place, index: true, foreign_key: true, null: false
      t.references :event, index: true, foreign_key: true, null: false
      t.references :score_type, index: true, foreign_key: true
      t.date :date, null: false
      t.datetime :published_at

      t.timestamps null: false
    end
  end
end
