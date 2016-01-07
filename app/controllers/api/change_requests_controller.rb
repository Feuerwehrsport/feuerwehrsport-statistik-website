module API
  class ChangeRequestsController < BaseController
    include CRUD::CreateAction
    include CRUD::IndexAction
    include CRUD::UpdateAction

    protected

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
