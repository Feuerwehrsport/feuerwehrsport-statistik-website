class Registrations::PeopleController < Registrations::BaseController
  default_actions :edit, :update, :destroy
  belongs_to Registrations::Competition, url: -> { registrations_competition_path(parent_resource) }

  default_form do |f|
    f.input :first_name
    f.input :last_name
    f.input :gender
    f.input :team_name
    f.input :tag_names
    f.fields_for :person_assessment_participations do
      f.association :assessment
      f.permit :_destroy
      f.permit :assessment_type
      f.permit :group_competitor_order
      f.permit :single_competitor_order
    end
  end

  protected

  def collection_redirect_url
    if resource.team.present?
      registrations_competition_team_path(parent_resource, resource.team)
    else
      registrations_competition_path(parent_resource)
    end
  end
end
