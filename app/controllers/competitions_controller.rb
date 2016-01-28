class CompetitionsController < ResourceController
  cache_actions :index, :show

  def index
    @competitions = Competition.with_disciplines_count.includes(:event, :place).decorate
    @chart = Chart::CompetitionsScoreOverview.new(competitions: @competitions)
    @competitions_discipline_overview = Calculation::CompetitionsScoreOverview.new(@competitions.map(&:id)).disciplines
  end

  def show
    @competition = Competition.find(params[:id]).decorate
    @calc = Calculation::Competition.new(@competition)
    @page_title = "#{@competition} - Wettkampf"
  end
end
