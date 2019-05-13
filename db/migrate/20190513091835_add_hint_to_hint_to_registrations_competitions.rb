class AddHintToHintToRegistrationsCompetitions < ActiveRecord::Migration
  def change
    add_column :registrations_competitions, :hint_to_hint, :text
  end
end
