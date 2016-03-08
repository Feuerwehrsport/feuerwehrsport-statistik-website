module CompReg
  class PeopleController < CompRegController
    include CRUD::NewAction
    include CRUD::CreateAction
    include CRUD::ShowAction
    include CRUD::EditAction
    include CRUD::UpdateAction
    include CRUD::DestroyAction

    before_action :assign_instance_for_edit, only: [:edit, :participations]

    def participations
    end
    
    protected

    def permitted_attributes
      super.permit(:first_name, :last_name, :gender, :competition_id, :person_id, :team_id, 
        tags_attributes: [:id, :_destroy, :name],
        person_assessment_participations_attributes: [ :id, :_destroy, :single_competitor_order, 
          :competition_assessment_id, :assessment_type, :group_competitor_order ]
      )
    end

    def build_instance
      @competition = Competition.find(params[:competition_id]) if params[:competition_id].present?
      @team = Team.find(params[:team_id]) if params[:team_id].present?
      resource_class.new(competition: @competition, admin_user: current_admin_user, team: @team)
    end

    def before_create_success
      if resource_instance.team.nil?
        deliver(CompetitionMailer, :new_person_registered, resource_instance)
        deliver(PersonMailer, :notification_to_creator, resource_instance)
      end
      redirect_to action: :participations, id: resource_instance.id
    end

    def before_update_success
      if resource_instance.team.present?
        redirect_to action: :show, controller: :teams, id: resource_instance.team_id
      else
        redirect_to action: :show, controller: :competitions, id: resource_instance.competition_id
      end
    end
  
    def before_destroy_success
      if resource_instance.team.present?
        redirect_to action: :show, controller: :teams, id: resource_instance.team_id
      else
        redirect_to action: :show, controller: :competitions, id: resource_instance.competition_id
      end
    end
  end
end
