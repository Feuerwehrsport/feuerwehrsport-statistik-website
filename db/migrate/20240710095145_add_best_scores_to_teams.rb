# frozen_string_literal: true

class AddBestScoresToTeams < ActiveRecord::Migration[7.0]
  def change
    add_column :teams, :best_scores, :jsonb, default: {}
  end
end
