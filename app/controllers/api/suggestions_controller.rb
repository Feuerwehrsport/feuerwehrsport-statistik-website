class API::SuggestionsController < API::BaseController
  def people
    suggestions = Person.limit(10)
    suggestions = suggestions.where_name_like(params[:name]) if params[:name]
    suggestions = suggestions.order_by_gender(params[:gender]) if params[:gender]
    suggestions = suggestions.gender(params[:real_gender]) if params[:real_gender]
    suggestions = suggestions.order_by_teams(Team.where_name_like(params[:team_name])) if params[:team_name]

    success(people: suggestions.decorate.map { |person| SuggestionPersonSerializer.new(person) })
  end

  # def teams
  #   suggestions = FireSportStatistics::Team.limit(10)
  #   suggestions = suggestions.where_name_like(params[:name]) if params[:name]

  #   render json: suggestions.to_json(
  #     only: [:name, :short]
  #   )
  # end
end