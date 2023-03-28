# frozen_string_literal: true

class Registrations::TeamCreationsController < Registrations::BaseController
  default_actions :new, :create, for_class: Registrations::Team
  belongs_to Registrations::Band, url: -> { collection_redirect_url }

  default_form do |f|
    f.inputs :allgemein do
      f.input :name
      f.input :shortcut
      f.input :team_id
    end
  end

  protected

  def build_resource
    super.tap do |resource|
      resource.admin_user = current_admin_user
      resource.team_leader = current_admin_user.name
      resource.email_address = current_admin_user.email_address
      resource.assessments = requestable_assessments(resource)
    end
  end

  def member_redirect_url
    edit_registrations_band_team_path(parent_resource, form_resource)
  end

  def after_create
    Registrations::CompetitionMailer.with(team: form_resource).new_team_registered.deliver_later
    Registrations::TeamMailer.with(team: form_resource).notification_to_creator.deliver_later
    super
  end

  def collection_redirect_url
    url_for(parent_resource.competition)
  end

  def requestable_assessments(team = form_resource)
    Registrations::Assessment.requestable_for(team)
  end
end
