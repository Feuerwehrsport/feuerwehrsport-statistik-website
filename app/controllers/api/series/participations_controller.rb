module API
  module Series
    class ParticipationsController < BaseController
      include CRUD::CreateAction
      include CRUD::ShowAction
      include CRUD::UpdateAction
      include CRUD::DestroyAction
      include CRUD::ChangeLogSupport

      protected

      def resource_class
        if action_name == "create"
          create_permitted_attributes[:person_id].present? ? ::Series::PersonParticipation : ::Series::TeamParticipation
        else
          super
        end
      end

      def update_permitted_attributes
        super.permit(:person_id, :team_id, :team_number, :rank, :points, :time)
      end

      def create_permitted_attributes
        super.permit(:cup_id, :assessment_id, :type, :person_id, :team_id, :team_number, :rank, :points, :time)
      end
    end
  end
end
