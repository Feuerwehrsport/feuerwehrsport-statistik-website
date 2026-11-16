# frozen_string_literal: true

class Backend::Series::RoundImportsController < Backend::BackendController
  backend_actions :new, :create
  belongs_to Series::Round, url: -> { collection_redirect_url }

  default_form do |f|
    f.value :round
    f.association :competition, as: :association_select
    f.association :import_request, as: :select
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
    if form_resource.import_now
      after_create
    else
      render :create
    end
  end

  protected

  def round_import_params
    params.require(resource_params_name).permit(:competition_id, :import_request_id, :import_now,
                                                person_assignments: {}, team_assignments: {})
  end

  def collection_redirect_url
    url_for([:backend, parent_resource])
  end
end
