class ExtendedTeamSerializer < TeamSerializer
  %i[fs gs la].each do |discipline|
    attributes :"#{discipline}_scores"

    define_method(:"#{discipline}_scores") do
      object.group_scores.discipline(discipline).decorate.map do |score|
        {
          id: score.id,
          competition: score.competition.to_s,
          competition_id: score.competition.id,
          team_number: score.team_number,
          second_time: score.second_time,
        }
      end
    end
  end

  attributes :single_scores

  def single_scores
    object.scores.decorate.map do |score|
      {
        id: score.id,
        competition: score.competition.to_s,
        competition_id: score.competition.id,
        team_number: score.team_number,
        second_time: score.second_time,
      }
    end
  end
end
