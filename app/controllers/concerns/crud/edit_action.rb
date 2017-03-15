module CRUD::EditAction
  extend ActiveSupport::Concern
  
  included do
    include CRUD::ObjectAssignment
    before_action :assign_instance_for_edit, only: :edit
  end

  def edit
  end

  protected

  def resource_instance_edit_object
    resource_instance
  end

  def assign_instance_for_edit
    assign_existing_instance
    authorize!(action_name.to_sym, resource_instance)
    self.resource_instance = resource_instance.decorate
  end
end