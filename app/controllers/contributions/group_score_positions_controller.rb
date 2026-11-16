# frozen_string_literal: true

# "Positionen bearbeiten": choose the person for one position of one run, saved directly
class Contributions::GroupScorePositionsController < Contributions::BaseController
  before_action :assign_group_score_and_position

  def edit
    @current_person = @group_score.person_participations.find_by(position: @position)&.person&.decorate
    @include_women = params[:include_women].present?
    @people = suggestions.map(&:decorate)
  end

  def update
    person = Person.find(params[:person_id]) if params[:person_id].present?
    assign_group_score_person(@group_score, @position, person)
    redirect_to edit_contributions_group_score_participations_path(@group_score, changed: 1)
  end

  private

  def assign_group_score_and_position
    @group_score = GroupScore.find(params[:group_score_id])
    authorize!(:person_participation, @group_score)
    @position = Integer(params[:position], exception: false)
    positions = 1..Discipline.participation_count(@group_score.discipline)
    raise ActiveRecord::RecordNotFound unless positions.cover?(@position)
  end

  # without search: people who often started at this position for the team, then team members
  def suggestions
    if params[:q].to_s.strip.length >= 2
      gender = @group_score.gender
      real_gender = gender unless gender.to_s == 'male' && @include_women
      People::Suggestions.new(name: params[:q].to_s.strip, order_team_id: @group_score.team_id, real_gender:).to_a
    else
      People::Suggestions.new(score_id: @group_score.id, position: @position, real_gender: @group_score.gender).to_a
    end
  end
end
