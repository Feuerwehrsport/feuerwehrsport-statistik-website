class CreateTeamSpellings < ActiveRecord::Migration
  def change
    create_table :team_spellings do |t|
      t.references :team, index: true, foreign_key: true
      t.string :name
      t.string :shortcut

      t.timestamps null: false
    end
  end
end
