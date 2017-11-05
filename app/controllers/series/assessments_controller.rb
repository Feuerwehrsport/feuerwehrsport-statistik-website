class Series::AssessmentsController < ResourceController
  resource_actions :show, cache: [:show]

  def show
    @person_assessments = Series::PersonAssessment.where(round: resource.round).where.not(id: resource.id).decorate

    configure_prawn(page_layout: :landscape) if request.format.pdf?
  end
end
