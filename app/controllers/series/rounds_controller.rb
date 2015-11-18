module Series
  class RoundsController < ResourceController
    def index
      @rows = Round.cup_count
    end

    def show
      round = Round.find(params[:id])
      @person_assessments = PersonAssessment.where(round: round).decorate
      @team_assessments_exists = TeamAssessment.where(round: round).present?
      @round = round.decorate
      @page_title = @round
    end
  end
end