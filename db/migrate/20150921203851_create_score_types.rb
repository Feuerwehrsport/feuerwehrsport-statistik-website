class CreateScoreTypes < ActiveRecord::Migration
  def change
    create_table :score_types do |t|
      t.integer :people, null: false
      t.integer :run, null: false
      t.integer :score, null: false

      t.timestamps null: false
    end
  end
end
