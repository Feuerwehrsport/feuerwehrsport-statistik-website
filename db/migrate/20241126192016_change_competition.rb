# frozen_string_literal: true

class ChangeCompetition < ActiveRecord::Migration[7.0]
  def change
    change_column_null :competitions, :name, true
    change_column_default :competitions, :name, nil
  end
end
