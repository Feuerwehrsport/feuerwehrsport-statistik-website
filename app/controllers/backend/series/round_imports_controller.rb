# frozen_string_literal: true

# import of the series results of an import request (Feusport) into a round: preview with the assignment of
# unknown people and teams, then the import ("Jetzt importieren")
class Backend::Series::RoundImportsController < Backend::BackendController
  backend_actions :new, :create
  belongs_to Series::Round, url: -> { collection_redirect_url }

  # the create action renders a preview page, Turbo expects a redirect
  default_form(html: { data: { turbo: false } }) do |f|
    f.value :round
    f.association :competition, as: :association_select
    f.association :import_request, as: :select, collection: ImportRequest.where.not(import_data: nil).decorate
  end

  # with competition and import request (link of the import request) the preview is shown directly
  def new
    return super if params.dig(resource_params_name, :competition_id).blank? ||
                    params.dig(resource_params_name, :import_request_id).blank?

    create
  end

  def create
    form_resource.assign_attributes(round_import_params)
    authorize!(:create, form_resource)
    return after_create_failed unless form_resource.valid?

    Caching::Cache.disable do
      ActiveRecord::Base.transaction do
        form_resource.save

        @person_assessments = ::Series::PersonAssessment.where(round: form_resource.round).decorate
        @team_assessments_exists = ::Series::TeamAssessment.where(round: form_resource.round).present?
        @preview_string = render_to_string(partial: 'backend/series/rounds/preview_changes',
                                           locals: { round: form_resource.round.decorate })
        raise ActiveRecord::Rollback unless form_resource.import_now
      end
    end

    self.resource = form_resource
    return render(:create) unless form_resource.import_now

    form_resource.import_request.mark_series_round_imported!(form_resource.round)
    after_create
  end

  protected

  def round_import_params
    params.require(resource_params_name).permit(:competition_id, :import_request_id, :import_now,
                                                person_assignments: {}, person_assignment_ids: {},
                                                team_assignments: {}, team_assignment_ids: {})
  end

  # back to the import request, it is the next step of the import
  def collection_redirect_url
    import_request = form_resource&.import_request if action_name == 'create'
    import_request ? backend_import_request_path(import_request) : url_for([:backend, parent_resource])
  end
end
