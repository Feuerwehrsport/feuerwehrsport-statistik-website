module API
  module CRUD
    module ShowAction
      extend ActiveSupport::Concern
      
      included do
        include CRUD::ObjectAssignment
        before_action :assign_instance_for_show, only: :show
      end

      def show
        success(resource_variable_name.to_sym => resource_instance_show_object, resource_name: resource_variable_name)
      end

      protected

      def resource_instance_show_object
        resource_instance
      end

      def assign_instance_for_show
        assign_existing_instance
        self.resource_instance = resource_instance.decorate
      end
    end
  end
end