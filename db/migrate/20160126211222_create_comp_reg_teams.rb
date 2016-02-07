class CreateCompRegTeams < ActiveRecord::Migration
  def change
    create_table :comp_reg_teams do |t|
      t.references :competition, null: false
      t.references :team, foreign_key: true
      t.string :name, null: false
      t.string :shortcut, null: false
      t.integer :gender, null: false
      t.references :admin_user, null: false
      t.timestamps null: false
    end
    add_foreign_key :comp_reg_teams, :comp_reg_competitions, column: :competition_id
    add_foreign_key :comp_reg_teams, :admin_users, column: :admin_user_id
  end
end
