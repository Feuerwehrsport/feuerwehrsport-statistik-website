module Backend
  module Series
    class RoundsController < BackendController
      def new
        @resouce_instance = Import::Series::Base.new
        @possible_types = Import::Series::Base::TYPES
      end

      def create
        ActiveRecord::Base.transaction do
          @resouce_instance = import_series_class.new(permitted_params)

          @person_assessments = ::Series::PersonAssessment.where(round: @resouce_instance.round).decorate
          @team_assessments_exists = ::Series::TeamAssessment.where(round: @resouce_instance.round).present?
          @round = @resouce_instance.round.decorate

          @preview_string = render_to_string(partial: 'backend/series/rounds/preview_changes')
          if @resouce_instance.perform_now != "1"
            raise ActiveRecord::Rollback.new
          else
            flash[:success] = "Wettkampf hinzugefügt"
            redirect_to action: :index
          end
        end
      end

      def index
        @rounds = {}
        ::Series::Round.pluck(:name).uniq.sort.each do |name|
          @rounds[name] = ::Series::Round.cup_count.where(name: name)
        end
      end

      def show
        round = ::Series::Round.find(params[:id])
        @person_assessments = ::Series::PersonAssessment.where(round: round).decorate
        @team_assessments_exists = ::Series::TeamAssessment.where(round: round).present?
        @round = round.decorate
        @page_title = "#{@round} - Wettkampfserie"
      end

      protected

      def permitted_params
        params.require(:import_series_base)
      end

      def import_series_class
        "Import::Series::#{permitted_params[:series_type]}".constantize
      end
    end
  end
end