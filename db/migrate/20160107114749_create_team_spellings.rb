class CreateTeamSpellings < ActiveRecord::Migration
  def change
    create_table :team_spellings do |t|
      t.references :team, null: false, index: true, foreign_key: true
      t.string :name, null: false
      t.string :shortcut, null: false

      t.timestamps null: false
    end
  end
end
