# frozen_string_literal: true

class Registrations::TeamsController < Registrations::BaseController
  default_actions :show, :edit, :update, :destroy
  belongs_to Registrations::Band, url: -> { collection_redirect_url }

  default_form do |f|
    f.inputs :allgemein do
      f.input :name
      f.input :team_number
      f.input :shortcut
    end
    f.inputs :team_leader do
      f.input :team_leader
      f.input :phone_number
      f.input :email_address
    end
    f.inputs :hint do
      f.value :hint_to_hint, label: '' if parent_resource.competition.hint_to_hint.present?
      f.input :hint
    end

    if parent_resource.team_tag_list.present?
      f.inputs :additional_data do
        f.input :tag_names, as: :check_boxes, collection: parent_resource.team_tag_list
      end
    end

    if requestable_assessments.present?
      f.inputs :assessments do
        f.association :assessments, as: :check_boxes, collection: requestable_assessments, label_method: :with_image
      end
    end
  end

  def show
    super

    if request.format.pdf?
      authorize!(:export, resource)
      send_pdf(Registrations::Teams::Pdf, resource)
    elsif request.format.xlsx?
      authorize!(:export, resource)
      response.headers['Content-Disposition'] = "attachment; filename=\"#{resource.decorate.to_s.parameterize}.xlsx\""
    end
  end

  protected

  def collection_redirect_url
    url_for(parent_resource.competition)
  end

  def requestable_assessments(team = form_resource)
    Registrations::Assessment.requestable_for(team)
  end
end
