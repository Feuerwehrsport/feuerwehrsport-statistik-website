module Series
  class AssessmentsController < ResourceController
    cache_actions :show
    def show
      @assessment = Assessment.find(params[:id]).decorate
      @person_assessments = PersonAssessment.where(round: @assessment.round).where.not(id: @assessment.id).decorate
      @page_title = "#{@assessment.round} #{@assessment} - Wettkampfserie"

      if request.format.pdf?
        prawnto(prawn: { page_layout: :landscape, page_size: 'A4', margin: [36, 36, 40, 36] })
      end
    end
  end
end