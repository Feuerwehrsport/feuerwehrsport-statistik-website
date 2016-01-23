module Backend
  class AdminUsersController < ResourcesController
    protected

    def permitted_attributes
      super.permit(:name, :email, :role)
    end
  end
end