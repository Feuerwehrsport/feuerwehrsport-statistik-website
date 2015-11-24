module Backend
  class AdminUsersController < ResourcesController
    protected

    def permitted_attributes
      super.permit(:email, :password, :password_confirmation)
    end
  end
end