module API
  module CRUD
    module IndexAction
      extend ActiveSupport::Concern
      
      included do
        include ObjectAssignment
        before_action :assign_collection_for_index, only: :index
      end

      def index
        if resource_collection.respond_to?(:index_order)
          self.resource_collection = resource_collection.index_order
        end
        success(resource_variable_name.pluralize.to_sym => resource_collection)
      end

      protected

      def assign_collection_for_index
        assign_collection
      end
    end
  end
end

