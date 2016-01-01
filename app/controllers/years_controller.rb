class YearsController < ResourceController
  def index
    @years = Year.competition_count.decorate
    @chart = Chart::YearIndex.new(years: @years)
  end

  def show
    @year = Year.find_by_year!(params[:id]).decorate
    @competitions = @year.competitions.with_disciplines_count.includes(:place, :event).decorate
    @chart = Chart::CompetitionsScoreOverview.new(competitions: @competitions)
    @competitions_discipline_overview = Calculation::CompetitionsScoreOverview.new(@competitions.map(&:id)).disciplines
    @page_title = "Jahr #{@year}"
  end

  def best_performance
    @year = Year.find_by_year!(params[:id]).decorate
    @performance_overview_disciplines = Calculation::PerformanceOfYear::Discipline.get(@year.year).map(&:decorate)
  end
end
