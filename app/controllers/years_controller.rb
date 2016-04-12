class YearsController < ResourceController
  cache_actions :index, :show, :best_performance, :best_scores

  def index
    @years = Year.competition_count.decorate
    @chart = Chart::YearIndex.new(years: @years)
  end

  def show
    @year = Year.find_by_year!(params[:id]).decorate
    @competitions = @year.competitions.includes(:place, :event).decorate
    @chart = Chart::CompetitionsScoreOverview.new(competitions: @competitions)
    @competitions_discipline_overview = Calculation::CompetitionsScoreOverview.new(@competitions.map(&:id)).disciplines
    @page_title = "Jahr #{@year}"
  end

  def best_performance
    @year = Year.find_by_year!(params[:id]).decorate
    @performance_overview_disciplines = Calculation::PerformanceOfYear::Discipline.get(@year.year).map(&:decorate)
  end

  def best_scores
    @year = Year.find_by_year!(params[:id]).decorate
    @discipline_structs = []
    [
      [:hb, :female],
      [:hb, :male],
      [:hl, :female],
      [:hl, :male],
      [:gs, :female],
      [:la, :female],
      [:la, :male],
    ].each do |discipline, gender|
      klass = Discipline.group?(discipline) ? GroupScore.regular : Score
      @discipline_structs.push OpenStruct.new(
        discipline: discipline,
        gender: gender,
        scores: klass.best_of_year(@year.object, discipline, gender).order(:time).decorate
      )
    end
  end
end
