class Registrations::PersonCreationsController < Registrations::BaseController
  default_actions :new, :create, for_class: Registrations::Person
  belongs_to Registrations::Competition

  default_form do |f|
    f.input :first_name
    f.input :last_name
    f.input :gender
    f.input :team_name if resource.team.blank?
    f.permit :team_id
    f.permit :person_id
  end

  protected

  def build_resource
    super.tap do |r|
      r.admin_user = current_admin_user
      r.team = Registrations::Team.find_by(id: params[:team_id])
    end
  end

  def after_create
    if form_resource.team.nil?
      deliver_later(Registrations::CompetitionMailer, :new_person_registered, form_resource)
      deliver_later(Registrations::PersonMailer, :notification_to_creator, form_resource)
    end
    super
  end

  def collection_redirect_url
    if resource.team.present?
      registrations_competition_team_path(parent_resource, resource.team)
    else
      registrations_competition_path(parent_resource)
    end
  end
end
