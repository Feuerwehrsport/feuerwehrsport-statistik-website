class API::ChangeRequestsController < API::BaseController
  api_actions :create, :index, :update,
              change_log: true, clean_cache_disabled: true,
              update_form: [:done]
  before_action :assign_instance_for_show_file, only: :files

  def files
    success(change_request_file: @change_request_file, resource_name: :change_request_file)
  end

  protected

  def build_resource
    resource_class.new(user: current_user)
  end

  def assign_instance_for_show_file
    self.resource = ChangeRequest.find(params[:change_request_id]).decorate
    @change_request_file = resource.files[params[:id].to_i].to_h
    raise ActiveRecord::RecordNotFound if @change_request_file.blank?
  end

  def resource_params
    if action_name == 'create'
      params[resource_params_name].permit(
        content: permit_scalar_attributes(params[resource_params_name][:content].permit!.to_h),
        files: [],
      )
    else
      super
    end
  end

  def after_create
    deliver_later(ChangeRequestMailer, :new_notification, resource)
    super
  end

  def permit_scalar_attributes(attributes)
    attributes.keys.map do |key|
      if attributes[key].is_a?(Hash)
        { key => permit_scalar_attributes(attributes[key]) }
      else
        key
      end
    end
  end
end
