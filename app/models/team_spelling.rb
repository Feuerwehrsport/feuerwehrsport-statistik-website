class TeamSpelling < ActiveRecord::Base
  belongs_to :team

  validates :team, :name, :shortcut
end
