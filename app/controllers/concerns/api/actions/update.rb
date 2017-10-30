module API::Actions::Update
  extend ActiveSupport::Concern

  protected

  def after_update
    success(resource_modulized_name.to_sym => resource_update_object, resource_name: resource_modulized_name)
  end

  def after_update_failed
    failed
  end

  def resource_update_object
    resource
  end
end
