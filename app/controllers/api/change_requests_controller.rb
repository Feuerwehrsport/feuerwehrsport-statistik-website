module API
  class ChangeRequestsController < BaseController
    include CRUD::CreateAction

    protected

    def permitted_attributes
      super_attributes = super
      super_attributes.permit(content: permit_scalar_attributes(super_attributes[:content]))
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
