class AddHintToRegistrationsTeams < ActiveRecord::Migration
  def change
    add_column :registrations_teams, :hint, :text
  end
end
