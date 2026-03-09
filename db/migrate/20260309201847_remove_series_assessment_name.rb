# frozen_string_literal: true

class RemoveSeriesAssessmentName < ActiveRecord::Migration[7.2]
  def change
    remove_column :series_person_assessments, :name
    remove_column :series_team_assessments, :name
  end
end
