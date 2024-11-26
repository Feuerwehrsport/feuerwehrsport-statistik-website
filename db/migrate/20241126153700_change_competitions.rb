# frozen_string_literal: true

class ChangeCompetitions < ActiveRecord::Migration[7.0]
  def change
    change_column_null :competitions, :hint_content, true
    change_column_default :competitions, :hint_content, nil
  end
end
