module Series
  class TeamParticipation < Participation
    belongs_to :team

    validates :team, :team_number, presence: true

    def entity_id
      "#{team_id}-#{team_number}"
    end
  end
end
