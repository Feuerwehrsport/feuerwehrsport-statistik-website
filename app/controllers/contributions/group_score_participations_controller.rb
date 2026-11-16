# frozen_string_literal: true

# "Positionen bearbeiten": overview of all runs of a team (similar scores) with the people per position
class Contributions::GroupScoreParticipationsController < Contributions::BaseController
  def edit
    @group_score = GroupScore.find(params[:group_score_id])
    authorize!(:person_participation, @group_score)
    @scores = @group_score.similar_scores.includes(person_participations: :person).decorate
    @positions = 1..Discipline.participation_count(@group_score.discipline)
    @changed = params[:changed].present?
  end
end
