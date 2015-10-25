module CRUD::ResourceAssignment
  extend ActiveSupport::Concern


  protected

  def base_collection
    resource_class.all
  end

  def assign_existing_resource
    self.resource_instance = find_resource
  end

  def find_resource
    base_collection.find(params[resource_param_id])
  end

  def assign_new_resource
    self.resource_instance = build_resource
  end

  def build_resource
    resource_class.new
  end

  def resource_param_id
    :id
  end
end