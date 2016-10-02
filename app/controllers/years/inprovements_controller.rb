class Years::InprovementsController < ResourceController
  def index
    @year = Year.find_by_year!(params[:year_id]).decorate
    @disciplines = [
      Years::Inprovement.new(@year.to_i, :hl, :female, @team),
      Years::Inprovement.new(@year.to_i, :hb, :female, @team),
      Years::Inprovement.new(@year.to_i, :hl, :male, @team),
      Years::Inprovement.new(@year.to_i, :hb, :male, @team),
    ]
  end

  def show
    @team = Team.find(params[:id])
    index
  end

  def page_title
    'Verbesserungen'
  end
end
