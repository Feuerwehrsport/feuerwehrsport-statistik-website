class API::AppointmentsController < API::BaseController
  api_actions :create, :show, :update,
              change_log: true,
              default_form: %i[name description dated_at disciplines place event_id]

  protected

  def build_resource
    super.tap { |r| r.assign_attributes(creator: current_user) }
  end

  def resource_show_object
    super.tap { |r| r.updateable = can?(:update, resource) }
  end

  def resource_update_object
    resource_show_object
  end
end
