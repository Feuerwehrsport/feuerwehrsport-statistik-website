# frozen_string_literal: true

class Registrations::AssessmentsController < Registrations::BaseController
  default_actions :new, :create, :edit, :update, :destroy
  belongs_to Registrations::Band, url: -> { collection_redirect_url }

  default_form do |f|
    f.value :band
    f.value :discipline, value: resource.decorate.discipline_name(resource.discipline)
    f.input :discipline, as: :hidden
    f.input :name
    f.input :show_only_name
  end

  def build_resource
    super.tap { |r| r.discipline = params[:discipline] }
  end

  def collection_redirect_url
    registrations_competition_bands_path(form_resource.competition)
  end
end
