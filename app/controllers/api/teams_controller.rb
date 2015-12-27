module API
  class TeamsController < BaseController
    include CRUD::CreateAction
    include CRUD::ShowAction
    include CRUD::IndexAction

    protected

    def permitted_attributes
      super.permit(:name, :shortcut, :status)
    end
  end
end
