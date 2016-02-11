class TeamSpelling < ActiveRecord::Base
  include TeamScopes
  belongs_to :team

  scope :search, -> (team_name) { where("name ILIKE ? OR shortcut ILIKE ?", team_name, team_name) }
  
  validates :team, :name, :shortcut, presence: true

  def self.create_from(team, incorrect_team)
    create!(team: team, name: incorrect_team.name, shortcut: incorrect_team.shortcut)
  end
end
