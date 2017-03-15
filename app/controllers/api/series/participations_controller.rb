class API::Series::ParticipationsController < API::BaseController
  include API::CRUD::CreateAction
  include API::CRUD::ShowAction
  include API::CRUD::IndexAction
  include API::CRUD::UpdateAction
  include API::CRUD::DestroyAction
  include API::CRUD::ChangeLogSupport

  protected

  def resource_class
    if action_name == "create"
      create_permitted_attributes[:person_id].present? ? ::Series::PersonParticipation : ::Series::TeamParticipation
    else
      super
    end
  end

  def update_permitted_attributes
    super.permit(:assessment_id, :person_id, :team_id, :team_number, :rank, :points, :time)
  end

  def create_permitted_attributes
    super.permit(:cup_id, :assessment_id, :type, :person_id, :team_id, :team_number, :rank, :points, :time)
  end
end