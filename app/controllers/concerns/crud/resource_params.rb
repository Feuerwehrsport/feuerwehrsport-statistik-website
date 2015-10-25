module CRUD::ResourceParams
  extend ActiveSupport::Concern


  protected

  def resource_params
    method_name = "#{resource_name}_params"
    send(method_name)
  end
end