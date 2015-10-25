class CreatePersonParticipations < ActiveRecord::Migration
  def change
    create_table :person_participations do |t|
      t.references :person, index: true, foreign_key: true, null: false
      t.references :group_score, index: true, foreign_key: true, null: false
      t.integer :position, null: false

      t.timestamps null: false
    end
  end
end
