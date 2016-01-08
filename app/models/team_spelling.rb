class TeamSpelling < ActiveRecord::Base
  belongs_to :team

  validates :team, :name, :shortcut, presence: true

  def self.create_from(team, incorrect_team)
    create!(team: team, name: incorrect_team.name, shortcut: incorrect_team.shortcut)
  end
end
