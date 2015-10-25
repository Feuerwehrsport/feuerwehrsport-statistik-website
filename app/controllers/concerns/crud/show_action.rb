module CRUD::ShowAction

  extend ActiveSupport::Concern

  included do
    include CRUD::ResourceAssignment
    before_action :assign_resource_for_show, only: :show
  end

  def show
  end


  protected

  def assign_resource_for_show
    assign_existing_resource
  end

end