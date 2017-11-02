class Series::AssessmentsController < ResourceController
  resource_actions :show, cache: [:show]

  def show
    @person_assessments = Series::PersonAssessment.where(round: resource.round).where.not(id: resource.id).decorate

    if request.format.pdf?
      configure_prawn(title: @page_title, page_layout: :landscape)
    end
  end
end
