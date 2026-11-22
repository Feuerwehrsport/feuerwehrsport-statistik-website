# frozen_string_literal: true

module DefaultActions::Destroy
  extend ActiveSupport::Concern

  included do
    before_action :assign_resource_for_destroy, only: :destroy
  end

  def destroy
    resource.destroy
    after_destroy
  rescue ActiveRecord::DeleteRestrictionError => e
    redirect_back_or_to(collection_redirect_url, alert: delete_restriction_message(e), status: :see_other)
  end

  protected

  def assign_resource_for_destroy
    assign_resource
  end

  # e.g. "Cannot delete record because of dependent links" (restrict_with_exception)
  def delete_restriction_message(error)
    name = error.message[/dependent (\w+)/, 1]
    klass = name && resource.class.reflect_on_association(name)&.klass
    records = klass ? klass.model_name.human(count: 2) : 'Einträge'
    "Kann nicht gelöscht werden, weil noch #{records} damit verbunden sind. Entferne sie zuerst."
  end

  def after_destroy
    redirect_to return_page_or_url(collection_redirect_url)
  end
end
