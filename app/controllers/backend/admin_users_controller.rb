class Backend::AdminUsersController < Backend::ResourcesController
  protected

  def permitted_attributes
    super.permit(:name, :email, :role)
  end
end