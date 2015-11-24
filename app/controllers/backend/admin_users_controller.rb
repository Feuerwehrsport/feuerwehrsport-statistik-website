module Backend
  class AdminUsersController < ResourcesController
    protected

    def permitted_attributes
      super.permit()
    end
  end
end