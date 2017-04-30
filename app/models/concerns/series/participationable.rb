module Series::Participationable
  extend ActiveSupport::Concern

  def team_count
    team_participations.pluck(:team_id, :team_number).uniq.count
  end

  def team_participations
    participations.where(type: Series::TeamParticipation)
  end

  def person_count
    person_participations.pluck(:person_id).uniq.count
  end

  def person_participations
    participations.where(type: Series::PersonParticipation)
  end
end