class Years::InprovementsController < ResourceController
  cache_actions :index, :show

  def index
    @year = Year.find_by!(year: params[:year_id]).decorate
    @disciplines = [
      Years::Inprovement.new(@year.to_i, :hl, :female, @team),
      Years::Inprovement.new(@year.to_i, @year.to_i < 2017 ? :hb : :hw, :female, @team),
      Years::Inprovement.new(@year.to_i, :hl, :male, @team),
      Years::Inprovement.new(@year.to_i, :hb, :male, @team),
    ]
    @page_title = 'Verbesserungen'
  end

  def show
    @team = Team.find(params[:id])
    index
  end
end
