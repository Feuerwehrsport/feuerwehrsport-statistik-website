module CRUD::DestroyAction
  extend ActiveSupport::Concern
  
  included do
    before_action :assign_instance_for_destroy, only: :destroy
    include CRUD::ObjectAssignment
  end

  def destroy
    destroy_instance ? before_destroy_success : before_destroy_failed
  end

  protected

  def assign_instance_for_destroy
    assign_existing_instance
    authorize!(action_name.to_sym, resource_instance)
    self.resource_instance = resource_instance.decorate
  end

  def before_destroy_success
    redirect_to action: :index
  end

  def before_destroy_failed
    redirect_to action: :show
  end
end