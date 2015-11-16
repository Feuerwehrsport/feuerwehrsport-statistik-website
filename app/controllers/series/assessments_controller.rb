module Series
  class AssessmentsController < ResourceController
    def show
      @assessment = Assessment.find(params[:id]).decorate
    end
  end
end