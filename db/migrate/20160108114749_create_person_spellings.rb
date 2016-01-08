class CreatePersonSpellings < ActiveRecord::Migration
  def change
    create_table :person_spellings do |t|
      t.references :person, null: false, index: true, foreign_key: true
      t.string :last_name, null: false
      t.string :first_name, null: false
      t.integer :gender, null: false
      t.boolean :official, null: false, default: false

      t.timestamps null: false
    end
  end
end
