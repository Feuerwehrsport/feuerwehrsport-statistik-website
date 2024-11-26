# frozen_string_literal: true

class ChangeTeams < ActiveRecord::Migration[7.0]
  def change
    change_column_null :teams, :state, true
    change_column_default :teams, :state, nil
  end
end
