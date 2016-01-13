module API
  class ChangeRequestsController < BaseController
    include CRUD::CreateAction
    include CRUD::IndexAction
    include CRUD::UpdateAction

    before_action :assign_instance_for_show_file, only: :files

    def files
      success(change_request_file: @change_request_file, resource_name: :change_request_file)
    end

    protected

    def build_instance
      resource_class.new(user: current_user)
    end

    def assign_instance_for_show_file
      self.resource_instance = ChangeRequest.find(params[:change_request_id]).decorate
      @change_request_file = resource_instance.files[params[:id].to_i].to_h
      raise ActiveRecord::RecordNotFound.new unless @change_request_file.present?
    end

    def create_permitted_attributes
      super_attributes = super
      super_attributes.permit(content: permit_scalar_attributes(super_attributes[:content]), files: [])
    end

    def update_permitted_attributes
      permitted_keys = []
      permitted_keys.push(:done) if can?(:done, resource_instance)
      super.permit(*permitted_keys)
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
end
