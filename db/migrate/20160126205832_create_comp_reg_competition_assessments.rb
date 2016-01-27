class CreateCompRegCompetitionAssessments < ActiveRecord::Migration
  def change
    create_table :comp_reg_competition_assessments do |t|
      t.references :competition, null: false
      t.string :discipline, null: false
      t.integer :gender, null: false

      t.timestamps null: false
    end
    add_foreign_key :comp_reg_competition_assessments, :comp_reg_competitions, column: :competition_id
  end
end
