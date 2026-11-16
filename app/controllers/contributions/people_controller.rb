# frozen_string_literal: true

class Contributions::PeopleController < Contributions::BaseController
  # optional: assign the new person to a position of a group score ("Positionen bearbeiten")
  before_action :assign_target_position

  def new
    @person = Person.new(gender: @target_group_score&.gender)
    authorize!(:create, @person)
  end

  def create
    @person = Person.new(params.expect(person: %i[first_name last_name gender nation_id]))
    authorize!(:create, @person)

    saved = Person.transaction do
      @person.save && log_change(@person, serializer: PersonSerializer)
    end
    return render(:new, status: :unprocessable_content) unless saved

    clean_cache
    if @target_group_score
      assign_group_score_person(@target_group_score, @target_position, @person)
      redirect_to edit_contributions_group_score_participations_path(@target_group_score, changed: 1)
    else
      render :created
    end
  end

  private

  def assign_target_position
    return if params[:group_score_id].blank?

    @target_group_score = GroupScore.find(params[:group_score_id])
    authorize!(:person_participation, @target_group_score)
    @target_position = Integer(params[:position], exception: false)
    positions = 1..Discipline.participation_count(@target_group_score.discipline)
    raise ActiveRecord::RecordNotFound unless positions.cover?(@target_position)
  end
end
