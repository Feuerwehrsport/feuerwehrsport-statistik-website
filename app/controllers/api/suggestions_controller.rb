class API::SuggestionsController < API::BaseController
  def people
    suggestions = Person.limit(10)
    suggestions = suggestions.where_name_like(params[:name]) if params[:name]
    suggestions = suggestions.order_by_gender(params[:gender]) if params[:gender]
    if params[:real_gender] && Person.gender_string?(params[:real_gender])
      suggestions = suggestions.gender(params[:real_gender])
    end
    suggestions = suggestions.order_by_teams(Team.where_name_like(params[:team_name])) if params[:team_name]
    if params[:order_team_id]
      suggestions = suggestions.order_by_teams(Team.where(Team.arel_table[:id].eq(params[:order_team_id])))
    end
    suggestions = suggestions.where(id: params[:person_id]) if params[:person_id]

    if params[:score_id]
      group_score = GroupScore.find(params[:score_id])
      person_participations = PersonParticipation.team(group_score.team_id).discipline(group_score.discipline)
      person_participations = person_participations.where(position: params[:position]) if params[:position].present?
      position_suggestions = suggestions.joins(person_participations: :group_score).merge(person_participations)
                                        .group(:id).order('COUNT(*) DESC')
      if position_suggestions.to_a.size <= 10
        team_suggestions = suggestions.where.not(id: position_suggestions.map(&:id))
                                      .where(id: TeamMember.where(team_id: group_score.team_id).select(:person_id))
                                      .limit(10 - position_suggestions.to_a.size)
        suggestions = position_suggestions + team_suggestions
      else
        suggestions = position_suggestions
      end
    end

    success(people: suggestions.map(&:decorate).map { |person| SuggestionPersonSerializer.new(person) })
  end

  def teams
    suggestions = Team.limit(10)
    suggestions = suggestions.where_name_like(params[:name]) if params[:name]
    success(teams: suggestions.decorate.map { |team| SuggestionTeamSerializer.new(team) })
  end
end
