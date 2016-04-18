class Backend::ImportRequestsController < Backend::ResourcesController
  protected

  def permitted_attributes
    attributes = [:file, :url, :date, :place_id, :event_id, :description, :remove_file]
    if can?(:update, resource_instance)
      attributes.push(:edit_user_id, :finished)
    end
    super.permit(*attributes)
  end

  def clean_cache?(action_name)
    false
  end

  def build_instance
    resource_class.new(admin_user: current_admin_user)
  end

  def after_create_success
    deliver(ImportRequestMailer, :new_request, resource_instance)
    super
  end
end
