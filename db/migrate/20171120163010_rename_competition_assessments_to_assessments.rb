class RenameCompetitionAssessmentsToAssessments < ActiveRecord::Migration
  def change
    rename_table :registrations_competition_assessments, :registrations_assessments
    rename_column :registrations_assessment_participations, :competition_assessment_id, :assessment_id
  end
end
