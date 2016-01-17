module API
  module CRUD
    module UpdateAction
      extend ActiveSupport::Concern
      
      included do
        before_action :assign_instance_for_update, only: :update
        include CRUD::ObjectAssignment
      end

      def update
        update_instance ? before_update_success : failed
      end

      protected

      def assign_instance_for_update
        assign_existing_instance
        self.resource_instance = resource_instance.decorate
      end

      def before_update_success
        success(resource_variable_name.to_sym => resource_instance, resource_name: resource_variable_name)
      end

      def update_instance
        resource_instance.assign_attributes(update_permitted_attributes)
        save_instance
      end

      def update_permitted_attributes
        permitted_attributes
      end
    end
  end
end