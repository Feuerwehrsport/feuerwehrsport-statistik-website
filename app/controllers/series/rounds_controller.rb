class Series::RoundsController < ResourceController
  resource_actions :show, :index, cache: %i[show index]

  def index
    @rounds = {}
    Series::Round.pluck(:name).uniq.sort.each do |name|
      @rounds[name] = Series::Round.cup_count.where(name: name).decorate
    end
    @page_title = 'Wettkampfserien'
  end

  def show
    @person_assessments = Series::PersonAssessment.where(round: resource).decorate
    @team_assessments_exists = Series::TeamAssessment.where(round: resource).present?

    if request.format.pdf?
      configure_prawn(title: @page_title, page_layout: :landscape)
    end
  end
end
