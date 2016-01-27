module API
  module CRUD
    module IndexAction
      extend ActiveSupport::Concern
      
      included do
        include ::CRUD::ObjectAssignment
        before_action :assign_collection_for_index, only: :index
      end

      def index
        if resource_collection.respond_to?(:index_order)
          self.resource_collection = resource_collection.index_order
        end
        self.resource_collection = resource_collection.accessible_by(current_ability)
        success(resource_variable_name.pluralize.to_sym => resource_collection.decorate)
      end

      protected

      def assign_collection_for_index
        assign_collection
        authorize!(action_name.to_sym, resource_class)
      end
    end
  end
end

