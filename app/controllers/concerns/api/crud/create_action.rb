module API
  module CRUD
    module CreateAction
      extend ActiveSupport::Concern
      
      included do
        include CRUD::ObjectAssignment
        before_action :assign_instance_for_create, only: :create
      end

      def create
        create_instance ? before_create_success : failed
      end

      protected

      def before_create_success
        success
      end

      def assign_instance_for_create
        assign_new_instance
      end

      def create_instance
        resource_instance.assign_attributes(permitted_attributes)
        authorize!(action_name, resource_instance)
        resource_instance.save
      end
    end
  end
end