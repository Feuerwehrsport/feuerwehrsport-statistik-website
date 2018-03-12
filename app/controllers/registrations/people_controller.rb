class Registrations::PeopleController < Registrations::BaseController
  default_actions :edit, :update, :destroy
  belongs_to Registrations::Competition

  default_form do |f|
    f.input :first_name
    f.input :last_name
    f.input :gender
    f.input :team_name
    f.input :competition_id
    f.input :person_id
    f.input :team_id
    f.input :registration_order
    f.fields_for :tags do
      f.input :id
      f.input :name
      f.input :_destroy
    end
    f.fields_for :person_assessment_participations do
      f.input :id
      f.input :single_competitor_order
      f.input :assessment_id
      f.input :assessment_type
      f.input :group_competitor_order
      f.input :_destroy
    end
  end

  protected

  def build_resource
    super.tap do |r|
      r.admin_user = current_admin_user
      r.team = Registrations::Team.find_by(id: params[:team_id])
    end
  end

  def collection_redirect_url
    if resource.team.present?
      url_for(action: :show, controller: 'registrations/teams', competition_id: parent_resource, id: resource.team_id)
    else
      url_for(action: :participations, id: resource.id)
    end
  end
end
