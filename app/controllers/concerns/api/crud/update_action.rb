module API::CRUD::UpdateAction
  extend ActiveSupport::Concern
  
  included do
    include ::CRUD::UpdateAction
    include InstanceMethods
  end

  module InstanceMethods
    def update
      update_instance ? before_update_success : failed
    end

    protected

    def before_update_success
      success(resource_variable_name.to_sym => resource_instance, resource_name: resource_variable_name)
    end
  end
end