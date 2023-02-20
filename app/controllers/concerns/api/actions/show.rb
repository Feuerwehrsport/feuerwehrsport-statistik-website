# frozen_string_literal: true

module Api::Actions::Show
  extend ActiveSupport::Concern

  def show
    success(resource_modulized_name.to_sym => resource_show_object, resource_name: resource_modulized_name)
  end

  protected

  def resource_show_object
    resource
  end
end
