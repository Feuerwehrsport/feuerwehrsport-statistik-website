module CRUD
  module NewAction
    extend ActiveSupport::Concern
    
    included do
      include ObjectAssignment
      before_action :assign_instance_for_new, only: :new
    end

    def new
    end

    protected

    def assign_instance_for_new
      assign_new_instance
    end
  end
end