class CreateSeriesRounds < ActiveRecord::Migration
  def change
    create_table :series_rounds do |t|
      t.string :name, null: false
      t.integer :year, null: false

      t.timestamps null: false
    end
  end
end
