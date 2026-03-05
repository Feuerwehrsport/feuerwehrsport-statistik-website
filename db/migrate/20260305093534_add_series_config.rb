# frozen_string_literal: true

class AddSeriesConfig < ActiveRecord::Migration[7.2]
  def change
    add_column :series_rounds, :team_assessments_config_jsonb, :jsonb, default: []
    add_column :series_rounds, :person_assessments_config_jsonb, :jsonb, default: []
  end
end
