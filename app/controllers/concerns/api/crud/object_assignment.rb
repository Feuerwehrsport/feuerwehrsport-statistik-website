module API
  module CRUD
    module ObjectAssignment
      extend ActiveSupport::Concern

      included do
        include ResourceAccessor
      end

      protected

      def failed_message
        resource_instance.errors.full_messages.join("\n")
      end

      def assign_collection
        self.resource_collection = find_collection
      end

      def base_collection
        resource_class.all
      end

      def find_collection
        collection = base_collection
        if resource_class.respond_to?(:search) and params[:search].present?
          collection = collection.search(params[:search])
        end
        collection
      end

      def assign_existing_instance
        self.resource_instance = find_instance
      end

      def find_instance
        resource_class.find(params[object_param_id])
      end

      def assign_new_instance
        self.resource_instance = build_instance
      end

      def build_instance
        resource_class.new
      end

      def object_param_id
        :id
      end
    end
  end
end