# frozen_string_literal: true

module DefaultActions::Edit
  extend ActiveSupport::Concern

  included do
    before_action :assign_resource_for_edit, only: :edit
  end

  def edit
    form_resource.assign_attributes(resource_params) if params[resource_params_name].present?
  end

  protected

  def assign_resource_for_edit
    assign_resource
  end
end
