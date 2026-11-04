# frozen_string_literal: true

module DefaultActions::Show
  extend ActiveSupport::Concern

  included do
    before_action :assign_resource_for_show, only: :show
  end

  def show; end

  protected

  def assign_resource_for_show
    assign_resource
  end
end
