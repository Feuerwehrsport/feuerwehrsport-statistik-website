class CreateSeriesCups < ActiveRecord::Migration
  def change
    create_table :series_cups do |t|
      t.references :round, null: false
      t.references :competition, null: false, foreign_key: true
      t.timestamps null: false
    end
    add_foreign_key :series_cups, :series_rounds, column: :round_id
  end
end
