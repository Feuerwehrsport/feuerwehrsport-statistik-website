# frozen_string_literal: true

class AddYearToCompetitions < ActiveRecord::Migration[7.0]
  def change
    add_column :competitions, :year, :integer
    Competition.update_all('year = EXTRACT(YEAR FROM DATE(competitions.date))')
    change_column_null :competitions, :year, false
    add_index :competitions, :year

    add_index :competitions, %i[id year]
    add_index :scores, %i[person_id single_discipline_id competition_id time], name: 'index_scores_for_year_overview'
  end
end
