class TeamCompetition < ActiveRecord::View
  belongs_to :team
  belongs_to :competition
end
