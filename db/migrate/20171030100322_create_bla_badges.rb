class CreateBLABadges < ActiveRecord::Migration
  def change
    create_table :bla_badges do |t|
      t.references :person, foreign_key: true, null: false
      t.string :status, null: false, limit: 200
      t.integer :year, null: false
      t.integer :hl_time
      t.integer :hl_score_id
      t.integer :hb_time, null: false
      t.integer :hb_score_id

      t.timestamps null: false
    end

    add_foreign_key :bla_badges, :scores, column: :hl_score_id
    add_index :bla_badges, :hl_score_id
    add_foreign_key :bla_badges, :scores, column: :hb_score_id
    add_index :bla_badges, :hb_score_id
    add_index :bla_badges, :person_id, unique: true
  end
end
