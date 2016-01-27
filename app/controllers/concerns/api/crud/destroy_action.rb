module API
  module CRUD
    module DestroyAction
      extend ActiveSupport::Concern
      
      included do
        before_action :assign_instance_for_destroy, only: :destroy
        include ::CRUD::ObjectAssignment
      end

      def destroy
        destroy_instance ? before_destroy_success : failed
      end

      protected

      def assign_instance_for_destroy
        assign_existing_instance
        self.resource_instance = resource_instance.decorate
      end

      def before_destroy_success
        success(resource_variable_name.to_sym => resource_instance, resource_name: resource_variable_name)
      end
    end
  end
end