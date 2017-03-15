module API::CRUD::ShowAction
  extend ActiveSupport::Concern
  
  included do
    include ::CRUD::ShowAction
    include InstanceMethods
  end

  module InstanceMethods
    def show
      success(resource_variable_name.to_sym => resource_instance_show_object, resource_name: resource_variable_name)
    end
  end
end