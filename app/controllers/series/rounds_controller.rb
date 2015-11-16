module Series
  class RoundsController < ResourceController
    def index
      @rows = Round.cup_count
    end

    def show
      round = Round.find(params[:id])
      @person_assessments = PersonAssessment.where(round: round).decorate
      @team_assessments = TeamAssessment.where(round: round).decorate
      @round = round.decorate
    end
  end
end