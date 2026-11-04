# frozen_string_literal: true

module DefaultActions::Create
  extend ActiveSupport::Concern

  included do
    before_action :assign_new_resource_for_create, only: :create
  end

  def create
    form_resource.assign_attributes(resource_params)
    authorize!(:create, form_resource) if form_resource.valid?
    if form_resource.save
      self.resource = form_resource
      after_create
    else
      log_active_record_errors('Create', form_resource)
      after_create_failed
    end
  end

  protected

  def assign_new_resource_for_create
    assign_new_resource
  end

  def after_create
    redirect_to return_page_or_url(member_redirect_url)
  end

  def after_create_failed
    flash.now[:alert] = default_error_message
    render :new
  end
end
