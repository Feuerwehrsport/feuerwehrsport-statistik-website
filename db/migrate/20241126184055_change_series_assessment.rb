# frozen_string_literal: true

class ChangeSeriesAssessment < ActiveRecord::Migration[7.0]
  def change
    change_column_null :series_assessments, :name, true
    change_column_default :series_assessments, :name, nil
  end
end
