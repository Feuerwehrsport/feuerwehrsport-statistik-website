class YearsController < ResourceController
  resource_actions :show, :index, cache: %i[show index best_performance best_scores]

  def index
    super
    @chart = Chart::YearIndex.new(years: collection.decorate, context: view_context)
  end

  def show
    competitions = @year.competitions.includes(:place, :event)
    @chart = Chart::CompetitionsScoreOverview.new(competitions: competitions, context: view_context)
    @competitions_discipline_overview = Calculation::CompetitionsScoreOverview.new(competitions.map(&:id)).disciplines
    @competitions = competitions.decorate
  end

  def best_performance
    assign_resource
    @performance_overview_disciplines = Calculation::PerformanceOfYear::Discipline.get(resource.year).map(&:decorate)
  end

  def best_scores
    assign_resource
    @discipline_structs = []
    hb_female_discipline = resource.to_i < 2017 ? %i[hb female] : %i[hw female]
    [
      hb_female_discipline,
      %i[hb male],
      %i[hl female],
      %i[hl male],
      %i[gs female],
      %i[la female],
      %i[la male],
    ].each do |discipline, gender|
      klass = Discipline.group?(discipline) ? GroupScore.regular : Score
      scores = klass.best_of_year(resource, discipline, gender).order(:time).decorate
      next if scores.to_a.blank?

      @discipline_structs.push OpenStruct.new(
        discipline: discipline,
        gender: gender,
        scores: scores,
      )
    end
  end

  protected

  def find_collection
    super.competition_count
  end
end
