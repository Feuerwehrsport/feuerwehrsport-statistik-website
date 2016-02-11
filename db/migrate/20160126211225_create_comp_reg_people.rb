class CreateCompRegPeople < ActiveRecord::Migration
  def change
    create_table :comp_reg_people do |t|
      t.references :competition, null: false
      t.references :team
      t.references :person, foreign_key: true
      t.references :admin_user, foreign_key: true, null: false
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.integer :gender, null: false

      t.timestamps null: false
    end
    add_foreign_key :comp_reg_people, :comp_reg_competitions, column: :competition_id
    add_foreign_key :comp_reg_people, :comp_reg_teams, column: :team_id
  end
end
