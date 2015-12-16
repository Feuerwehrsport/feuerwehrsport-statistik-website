module API
  class TeamsController < BaseController
    include CRUD::CreateAction

    protected

    def permitted_attributes
      super.permit(:name, :shortcut, :status)
    end
  end
end
