class Series::TeamParticipationSerializer < Series::ParticipationSerializer
  attributes :team_id, :team_number, :participation_type

  def participation_type
    :team
  end
end
