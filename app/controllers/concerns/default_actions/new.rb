# frozen_string_literal: true

module DefaultActions::New
  extend ActiveSupport::Concern

  included do
    before_action :assign_new_resource_for_new, only: :new
  end

  def new
    form_resource.assign_attributes(resource_params) if params[resource_params_name].present?
  end

  protected

  def assign_new_resource_for_new
    assign_new_resource
  end
end
