class CreateCompRegAssessmentParticipations < ActiveRecord::Migration
  def change
    create_table :comp_reg_assessment_participations do |t|
      t.string :type, null: false

      t.references :competition_assessment, null: false
      t.references :team
      t.references :person

      t.timestamps null: false
    end
    add_foreign_key :comp_reg_assessment_participations, :comp_reg_competition_assessments, column: :competition_assessment_id
    add_foreign_key :comp_reg_assessment_participations, :comp_reg_teams, column: :team_id
    add_foreign_key :comp_reg_assessment_participations, :comp_reg_people, column: :person_id
  end
end
