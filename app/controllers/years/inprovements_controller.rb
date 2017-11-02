class Years::InprovementsController < ResourceController
  cache_actions :index, :show

  def index
    @year = Year.find_by!(year: params[:year_id]).decorate
    hb_female_discipline = @year.to_i < 2017 ? :hb : :hw
    hb_female_discipline = %i[hb hw] if @year.to_i == 2017
    @disciplines = [
      Years::Inprovement.new(@year.to_i, :hl, :female, @team),
      Years::Inprovement.new(@year.to_i, hb_female_discipline, :female, @team),
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
