module API
  module CRUD
    module CreateAction
      extend ActiveSupport::Concern
      
      included do
        include ::CRUD::CreateAction
        include InstanceMethods
      end

      module InstanceMethods
        def create
          create_instance ? before_create_success : failed
        end

        protected

        def before_create_success
          success
        end
      end
    end
  end
end