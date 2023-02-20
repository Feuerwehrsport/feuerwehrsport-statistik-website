# frozen_string_literal: true

class Backend::Series::RoundImportsController < Backend::BackendController
  backend_actions :new, :create
  belongs_to Series::Round, url: -> { collection_redirect_url }

  default_form do |f|
    f.value :round
    f.association :competition, as: :association_select
  end

  def create
    form_resource.assign_attributes(params[resource_params_name].permit!)
    authorize!(:create, form_resource)
    Caching::Cache.disable do
      ActiveRecord::Base.transaction do
        form_resource.save

        @person_assessments = ::Series::PersonAssessment.where(round: form_resource.round).decorate
        @team_assessments_exists = ::Series::TeamAssessment.where(round: form_resource.round).present?
        @preview_string = render_to_string(partial: 'backend/series/rounds/preview_changes',
                                           locals: { round: form_resource.round.decorate })
        raise ActiveRecord::Rollback unless form_resource.import_now?
      end
    end

    self.resource = form_resource
    if form_resource.import_now?
      after_create
    else
      render :create
    end
  end

  protected

  def collection_redirect_url
    url_for([:backend, parent_resource])
  end
end
