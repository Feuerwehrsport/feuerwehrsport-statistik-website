# frozen_string_literal: true

module DefaultActions::Update
  extend ActiveSupport::Concern

  included do
    before_action :assign_resource_for_update, only: :update
  end

  def update
    form_resource.assign_attributes(resource_params)
    authorize!(:update, form_resource) if form_resource.valid?
    if form_resource.save
      self.resource = form_resource
      after_update
    else
      log_active_record_errors('Update', form_resource)
      after_update_failed
    end
  end

  protected

  def assign_resource_for_update
    assign_resource
  end

  def after_update
    redirect_to return_page_or_url(member_redirect_url)
  end

  def after_update_failed
    flash.now[:alert] = default_error_message
    render :edit
  end
end
