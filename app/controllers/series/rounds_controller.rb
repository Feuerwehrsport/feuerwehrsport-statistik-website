class Series::RoundsController < ResourceController
  resource_actions :show, :index, cache: %i[show index single]
  helper_method :single_round?

  def index
    @rounds = {}
    all = Series::Round.uniq.reorder(:name)
    all = all.where(slug: params[:slug]) if single_round?
    all.pluck(:name).each do |name|
      @rounds[name] = Series::Round.cup_count.where(name: name).decorate
      @page_title = name
      @aggregate_type = @rounds[name].first.aggregate_type if single_round?
    end
    @page_title = 'Wettkampfserien' unless single_round?
  end

  def show
    @person_assessments = Series::PersonAssessment.where(round: resource).decorate
    @team_assessments_exists = Series::TeamAssessment.where(round: resource).present?

    send_pdf(Series::Rounds::Pdf, resource) if request.format.pdf?
  end

  def single_round?
    @single_round ||= params[:slug].present? && params[:slug] != 'rounds'
  end
end
