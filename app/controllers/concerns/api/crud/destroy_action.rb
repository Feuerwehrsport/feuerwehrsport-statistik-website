module API::CRUD::DestroyAction
  extend ActiveSupport::Concern
  
  included do
    include ::CRUD::DestroyAction
    include InstanceMethods
  end

  module InstanceMethods

    protected

    def before_destroy_success
      success(resource_variable_name.to_sym => resource_instance, resource_name: resource_variable_name)
    end

    def before_destroy_failed
      failed
    end
  end
end