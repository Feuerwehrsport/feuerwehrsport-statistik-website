class CreateCompRegCompetitionsMails < ActiveRecord::Migration
  def change
    create_table :comp_reg_competitions_mails do |t|
      t.references :competition, index: true
      t.references :admin_user, index: true, foreign_key: true
      t.boolean :add_registration_file, null: false, default: true
      t.string :subject
      t.text :text


      t.timestamps null: false
    end
    add_foreign_key :comp_reg_competitions_mails, :comp_reg_competitions, column: :competition_id
  end
end
