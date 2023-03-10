# frozen_string_literal: true

class Series::RoundsController < ResourceController
  resource_actions :show, :index, cache: %i[show index single]

  def index
    @kind = Series::Kind.find_by!(slug: params[:slug])
    @rounds = @kind.rounds.cup_count.decorate
    raise ActiveRecord::RecordNotFound if @rounds.empty?

    @page_title = @kind.name
    @aggregate_type = @rounds.first.aggregate_type
  end

  def show
    @person_assessments = Series::PersonAssessment.where(round: resource).decorate
    @team_assessments_exists = Series::TeamAssessment.where(round: resource).present?

    send_pdf(Series::Rounds::Pdf, resource) if request.format.pdf?
  end
end
