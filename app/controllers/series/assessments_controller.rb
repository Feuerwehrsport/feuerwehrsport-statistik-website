class Series::AssessmentsController < ResourceController
  cache_actions :show
  def show
    @assessment = Assessment.find(params[:id]).decorate
    @person_assessments = PersonAssessment.where(round: @assessment.round).where.not(id: @assessment.id).decorate
    @page_title = "#{@assessment.round} #{@assessment} - Wettkampfserie"

    if request.format.pdf?
      configure_prawn(title: @page_title, page_layout: :landscape)
    end
  end
end