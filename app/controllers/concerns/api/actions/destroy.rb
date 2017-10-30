module API::Actions::Destroy
  extend ActiveSupport::Concern

  protected

  def after_destroy
    success(resource_modulized_name.to_sym => resource_destroy_object, resource_name: resource_modulized_name)
  end

  def after_destroy_failed
    failed
  end

  def resource_destroy_object
    resource
  end

  def resource_show_object
    resource
  end
end
