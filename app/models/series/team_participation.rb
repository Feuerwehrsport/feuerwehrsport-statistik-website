module Series
  class TeamParticipation < Participation
    belongs_to :team

    validates :team, :team_number, presence: true
  end
end
