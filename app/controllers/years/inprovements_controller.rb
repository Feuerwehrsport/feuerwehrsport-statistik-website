# frozen_string_literal: true

class Years::InprovementsController < ResourceController
  cache_actions :index, :show

  def index
    @year = Year.find_by!(year: params[:year_id]).decorate
    @disciplines = []
    SingleDiscipline.gall.each do |single_discipline|
      Genderable::GENDER_KEYS.each do |gender|
        @disciplines.push(Years::Inprovement.new(@year.to_i, single_discipline, gender, @team))
      end
    end
    @disciplines.compact_blank!
    @page_title = 'Verbesserungen'
  end

  def show
    @team = Team.find(params[:id])
    index
  end
end
