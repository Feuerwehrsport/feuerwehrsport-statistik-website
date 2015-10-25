class CreatePeople < ActiveRecord::Migration
  def change
    create_table :people do |t|
      t.string :last_name, null: false
      t.string :first_name, null: false
      t.integer :gender, null: false, index: true
      t.references :nation, index: true, foreign_key: true, null: false

      t.timestamps null: false
    end
  end
end
