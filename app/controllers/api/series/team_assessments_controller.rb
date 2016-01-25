module API
  module Series
    class TeamAssessmentsController < BaseController
      include CRUD::IndexAction

      protected

      def base_collection
        if params[:round_id].present?
          super.round(params[:round_id])
        else
          super
        end
      end
    end
  end
end