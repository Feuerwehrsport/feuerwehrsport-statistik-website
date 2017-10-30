class MoveCompRegToRegistrations < ActiveRecord::Migration
  def change
    rename_table :comp_reg_assessment_participations, :registrations_assessment_participations
    rename_table :comp_reg_competition_assessments, :registrations_competition_assessments
    rename_table :comp_reg_competitions, :registrations_competitions
    rename_table :comp_reg_competitions_mails, :registrations_competitions_mails
    rename_table :comp_reg_people, :registrations_people
    rename_table :comp_reg_teams, :registrations_teams
  end
end
