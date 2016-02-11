class CreateCompRegCompetitions < ActiveRecord::Migration
  def change
    create_table :comp_reg_competitions do |t|
      t.string :name, null: false
      t.date :date, null: false
      t.string :place, null: false
      t.text :description, null: false
      t.datetime :open_at
      t.datetime :close_at
      t.references :admin_user, null: false, foreign_key: true
      t.string :person_tags, null: false, default: ""
      t.string :team_tags, null: false, default: ""

      t.timestamps null: false
    end
  end
end
