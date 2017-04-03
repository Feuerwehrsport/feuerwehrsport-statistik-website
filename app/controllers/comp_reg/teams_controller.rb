class CompReg::TeamsController < CompReg::CompRegController
  include CRUD::NewAction
  include CRUD::CreateAction
  include CRUD::ShowAction
  include CRUD::EditAction
  include CRUD::UpdateAction
  include CRUD::DestroyAction

  before_action :assign_step_for_form, only: [:new, :create, :edit, :update]

  def show
    super

    format = request.format.to_sym
    if format.in?([:xlsx, :pdf])
      authorize!(:export, resource_instance)
      response.headers['Content-Disposition'] = "attachment; filename=\"#{resource_instance.to_s.parameterize}.#{format}\""
    end
  end

  protected

  def permitted_attributes
    super.permit(:name, :shortcut, :gender, :competition_id, :team_number, :team_leader, :street_with_house_number, 
      :postal_code, :locality, :phone_number, :email_address, :federal_state_id,
      tags_attributes: [:id, :_destroy, :name],
      team_assessment_participations_attributes: [:id, :_destroy, :competition_assessment_id],
      people_attributes: [:id, :_destroy, :first_name, :last_name, :gender, :competition_id,
        person_assessment_participations_attributes: [:id, :_destroy, :single_competitor_order, :competition_assessment_id]
      ]
    )
  end

  def build_instance
    @competition = CompReg::Competition.find(params[:competition_id]) if params[:competition_id].present?
    resource_class.build_from_last(competition: @competition, admin_user: current_admin_user)
  end

  def save_instance
    if @step == 2
      super
    else
      resource_instance.valid?
      false
    end
  end

  def assign_step_for_form
    @step = params[:step].to_i
  end

  def before_destroy_success
    redirect_to controller: :competitions, id: resource_instance.competition_id, action: :show
  end

  def before_create_success
    deliver(CompReg::CompetitionMailer, :new_team_registered, resource_instance)
    deliver(CompReg::TeamMailer, :notification_to_creator, resource_instance)
    super
  end
end