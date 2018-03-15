class Registrations::RegistrationTimesController < Registrations::BaseController
  default_actions :edit, :update, for_class: Registrations::Competition
  belongs_to Registrations::Competition, url: -> { collection_redirect_url }

  default_form do |f|
    f.input :open_at
    f.input :close_at
  end

  protected

  def find_resource
    parent_resource
  end

  def collection_redirect_url
    url_for(parent_resource)
  end
end
