class CreateCompRegCompetitions < ActiveRecord::Migration
  def change
    create_table :comp_reg_competitions do |t|
      t.string :name, null: false, default: ""
      t.date :date, null: false
      t.string :place, null: false
      t.references :admin_user, null: false, foreign_key: true

      t.timestamps null: false
    end
  end
end
