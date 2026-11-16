# frozen_string_literal: true

# "Mannschaften bearbeiten" of single scores: team and team number for all scores of the person at the competition
class Contributions::ScoreTeamsController < Contributions::BaseController
  TEAM_NUMBERS = {
    -5 => 'Außer der Wertung', -4 => 'Achtelfinale', -3 => 'Viertelfinale', -2 => 'Halbfinale', -1 => 'Finale',
    0 => 'Einzelstarter', 1 => 'Mannschaft 1', 2 => 'Mannschaft 2', 3 => 'Mannschaft 3', 4 => 'Mannschaft 4',
    5 => 'Mannschaft 5'
  }.freeze
  NO_TEAM = 'none'

  before_action :assign_scores

  # step 1 without team_id: choose the team, step 2 with team_id: team number per score
  def edit
    @team = selected_team
    @teams = suggested_teams if @team.nil?
  end

  def update
    @team = selected_team
    numbers = @scores.index_with { |score| team_number_param(score) }
    if @team.nil? || numbers.values.any?(&:nil?)
      @error = 'Bitte wähle eine Mannschaft und für jeden Lauf eine Wertung.'
      @teams = suggested_teams if @team.nil?
      return render :edit, status: :unprocessable_content
    end

    Score.transaction do
      @scores.each do |score|
        before_hash = ScoreSerializer.new(score.decorate).as_json
        score.update!(team_id: team_id_value, team_number: numbers[score])
        log_change(score, serializer: ScoreSerializer, action: 'update-score:team', before_hash:)
      end
    end
    clean_cache
    render :updated
  end

  private

  def assign_scores
    score = Score.find(params[:score_id])
    authorize!(:update, score)
    @person = score.person.decorate
    @competition = score.competition.decorate
    @scores = Score.where(competition_id: score.competition_id, person_id: score.person_id).order(:id).to_a
    @current_team = score.team
  end

  # Team, :none (explicitly without team) or nil (not chosen yet)
  def selected_team
    return :none if params[:team_id] == NO_TEAM
    return if params[:team_id].blank?

    Team.find_by(id: params[:team_id])
  end

  # selected team number of a score, nil when missing or not allowed
  def team_number_param(score)
    number = Integer(params.dig(:team_numbers, score.id.to_s).to_s, exception: false)
    number if TEAM_NUMBERS.key?(number)
  end

  def team_id_value
    @team == :none ? nil : @team.id
  end

  # teams of the person and the current team, or search results
  def suggested_teams
    teams = if params[:q].to_s.strip.length >= 2
              Team.where_name_like(params[:q].to_s)
            else
              Team.where(id: TeamMember.where(person_id: @person.id).select(:team_id)).or(Team.where(id: @current_team))
            end
    teams.reorder(:name).limit(30)
  end
end
