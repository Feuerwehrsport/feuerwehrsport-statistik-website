# frozen_string_literal: true

module DefaultActions::Destroy
  extend ActiveSupport::Concern

  included do
    before_action :assign_resource_for_destroy, only: :destroy
  end

  def destroy
    resource.destroy
    after_destroy
  end

  protected

  def assign_resource_for_destroy
    assign_resource
  end

  def after_destroy
    redirect_to return_page_or_url(collection_redirect_url)
  end
end
