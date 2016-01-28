module API
  module CRUD
    module IndexAction
      extend ActiveSupport::Concern
      
      included do
        include ::CRUD::IndexAction
        include InstanceMethods
      end

      module InstanceMethods

        def index
          success(resource_variable_name.pluralize.to_sym => resource_collection.decorate)
        end
      end
    end
  end
end

