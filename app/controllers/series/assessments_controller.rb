# frozen_string_literal: true

class Series::AssessmentsController < ResourceController
  resource_actions :show, cache: [:show]

  def show
    @person_assessments = Series::PersonAssessment.where(round: resource.round).where.not(id: resource.id).decorate

    send_pdf(Series::Assessments::Pdf, resource) if request.format.pdf?
  end
end
