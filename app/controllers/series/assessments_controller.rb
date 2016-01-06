module Series
  class AssessmentsController < ResourceController
    def show
      @assessment = Assessment.find(params[:id]).decorate
      @person_assessments = PersonAssessment.where(round: @assessment.round).where.not(id: @assessment.id).decorate
    end
  end
end