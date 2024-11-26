# frozen_string_literal: true

class RemoveRegistrations < ActiveRecord::Migration[7.0]
  def change
    drop_table :registrations_assessment_participations
    drop_table :registrations_assessments
    drop_table :registrations_people
    drop_table :registrations_teams
    drop_table :registrations_bands
    drop_table :registrations_competitions
  end
end
