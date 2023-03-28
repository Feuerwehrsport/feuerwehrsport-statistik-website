# frozen_string_literal: true

class Registrations::PersonParticipationsController < Registrations::BaseController
  default_actions :edit, :update, for_class: Registrations::Person
  belongs_to Registrations::Band, url: -> { collection_redirect_url }

  default_form do |f|
    f.fields_for :person_assessment_participations do
      f.association :assessment
      f.permit :_destroy
      f.permit :assessment_type
      f.permit :group_competitor_order
      f.permit :single_competitor_order
      f.permit :competitor_order
    end
  end

  protected

  def collection_redirect_url
    if resource.team.present?
      registrations_band_team_path(parent_resource, resource.team_id)
    else
      registrations_competition_path(parent_resource.competition)
    end
  end
end
