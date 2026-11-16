# frozen_string_literal: true

# Suggestions of people for selections (api: /api/suggestions/people, dialog "Positionen bearbeiten").
# With score_id: first people who often started at the position for the team, then other team members.
class People::Suggestions
  LIMIT = 10

  def initialize(name: nil, gender: nil, real_gender: nil, team_name: nil, order_team_id: nil, person_id: nil,
                 score_id: nil, position: nil)
    @name = name
    @gender = gender
    @real_gender = real_gender
    @team_name = team_name
    @order_team_id = order_team_id
    @person_id = person_id
    @score_id = score_id
    @position = position
  end

  def to_a
    @score_id ? position_suggestions(filtered) : filtered.order(:id).to_a # stable order for equal values
  end

  private

  def filtered
    suggestions = Person.limit(LIMIT)
    suggestions = suggestions.where_name_like(@name) if @name
    suggestions = suggestions.order_by_gender(@gender) if @gender
    suggestions = suggestions.gender(@real_gender) if @real_gender && Person.gender_string?(@real_gender)
    suggestions = suggestions.order_by_teams(Team.where_name_like(@team_name)) if @team_name
    suggestions = suggestions.order_by_teams(Team.where(Team.arel_table[:id].eq(@order_team_id))) if @order_team_id
    suggestions = suggestions.where(id: @person_id) if @person_id
    suggestions
  end

  def position_suggestions(suggestions)
    group_score = GroupScore.find(@score_id)
    participations = PersonParticipation.team(group_score.team_id).discipline(group_score.discipline)
    participations = participations.where(position: @position) if @position.present?
    by_position = suggestions.joins(person_participations: :group_score).merge(participations)
                             .group(:id).order(Arel.sql('COUNT(*) DESC'), :id).to_a
    return by_position if by_position.size > LIMIT

    team_members = suggestions.where.not(id: by_position.map(&:id))
                              .where(id: TeamMember.where(team_id: group_score.team_id).select(:person_id))
                              .order(:id).limit(LIMIT - by_position.size)
    by_position + team_members.to_a
  end
end
