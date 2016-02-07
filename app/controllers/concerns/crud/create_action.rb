module CRUD
  module CreateAction
    extend ActiveSupport::Concern
    
    included do
      include ObjectAssignment
      before_action :assign_instance_for_create, only: :create
    end

    def create
      create_instance ? before_create_success : before_create_failed
    end

    protected

    def before_create_failed
      render :new
    end

    def before_create_success
      redirect_to action: :show, id: resource_instance.id
    end

    def assign_instance_for_create
      assign_new_instance
    end

    def create_instance
      resource_instance.assign_attributes(create_permitted_attributes)
      authorize!(action_name.to_sym, resource_instance)
      save_instance
    end

    def create_permitted_attributes
      permitted_attributes
    end
  end
end