class CompetitionsController < ResourceController
  def index
    @competitions = Competition.with_disciplines_count.includes(:event, :place).decorate
    @chart = Chart::CompetitionsScoreOverview.new(competitions: @competitions)
    @competitions_discipline_overview = Calculation::CompetitionsScoreOverview.new(@competitions.map(&:id)).disciplines
  end

  def show
    @competition = Competition.find(params[:id]).decorate
    @calc = Calculation::Competition.new(@competition)
  end

  def files
    @competition = Competition.find(params[:id])

    @competition_files = params.require(:competition_file).values.map do |competition_file_params|
      CompetitionFile.new(competition: @competition, file: competition_file_params[:file], keys_params: competition_file_params)
    end

    if @competition_files.all?(&:valid?)
      @saved = @competition_files.all?(&:save)
    else
      @saved = false
    end
  end
end
