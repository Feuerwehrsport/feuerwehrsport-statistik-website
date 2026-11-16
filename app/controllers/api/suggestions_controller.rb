# frozen_string_literal: true

class Api::SuggestionsController < Api::BaseController
  def people
    options = params.permit(:name, :gender, :real_gender, :team_name, :order_team_id, :person_id, :score_id, :position)
    suggestions = People::Suggestions.new(**options.to_h.symbolize_keys).to_a
    success(people: suggestions.map(&:decorate).map { |person| SuggestionPersonSerializer.new(person) })
  end

  def teams
    suggestions = Team.limit(10)
    suggestions = suggestions.where_name_like(params[:name]) if params[:name]
    success(teams: suggestions.decorate.map { |team| SuggestionTeamSerializer.new(team) })
  end
end
