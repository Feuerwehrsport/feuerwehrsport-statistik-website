module Series
  class RoundsController < ResourceController
    cache_actions :index, :show
    
    def index
      @rounds = {}
      Series::Round.pluck(:name).uniq.sort.each do |name|
        @rounds[name] = Round.cup_count.where(name: name)
      end
    end

    def show
      round = Round.find(params[:id])
      @person_assessments = PersonAssessment.where(round: round).decorate
      @team_assessments_exists = TeamAssessment.where(round: round).present?
      @round = round.decorate
      @page_title = "#{@round} - Wettkampfserie"

      if request.format.pdf?
        prawnto(prawn: { page_layout: :landscape, page_size: 'A4', margin: [36, 36, 40, 36] })
      end
    end
  end
end