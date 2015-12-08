module API
  module CRUD
    module ResourceAccessor
      extend ActiveSupport::Concern

      included do
        helper_method :resource_instance
        helper_method :resource_collection
        helper_method :resource_class
      end

      class_methods do
        def resource_variable_name
          controller_name.singularize
        end

        def resource_class
          begin
            controller_path.classify.constantize
          rescue NameError
            begin
              controller_name.classify.constantize
            rescue NameError
              nil
            end
          end
        end
      end

      def resource_instance
        instance_variable_get("@#{resource_variable_name}")
      end

      def resource_instance=(new_object)
        instance_variable_set("@#{resource_variable_name}", new_object)
      end

      def resource_variable_name
        self.class.resource_variable_name
      end

      def resource_class
        self.class.resource_class
      end

      def resource_collection
        instance_variable_get("@#{controller_name}")
      end

      def resource_collection=(new_collection)
        instance_variable_set("@#{controller_name}", new_collection)
      end

      def permitted_attributes
        params.require(resource_variable_name)
      end
    end
  end
end