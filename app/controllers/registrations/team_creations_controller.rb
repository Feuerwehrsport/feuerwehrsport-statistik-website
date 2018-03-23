class Registrations::TeamCreationsController < Registrations::BaseController
  default_actions :new, :create, for_class: Registrations::Team
  belongs_to Registrations::Competition, url: -> { collection_redirect_url }

  default_form do |f|
    f.inputs :allgemein do
      f.input :name
      f.input :shortcut
      f.input :gender
      f.input :team_id
    end
  end

  protected

  def build_resource
    super.tap do |resource|
      resource.admin_user = current_admin_user
      resource.assessments = requestable_assessments(resource)
    end
  end

  def member_redirect_url
    edit_registrations_competition_team_path(parent_resource, form_resource)
  end

  def after_create
    deliver_later(Registrations::CompetitionMailer, :new_team_registered, form_resource)
    deliver_later(Registrations::TeamMailer, :notification_to_creator, form_resource)
    super
  end

  def collection_redirect_url
    url_for(parent_resource)
  end

  def requestable_assessments(team = form_resource)
    Registrations::Assessment.requestable_for(team)
  end
end
