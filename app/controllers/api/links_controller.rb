module API
  class LinksController < BaseController
    include CRUD::CreateAction
    include CRUD::ShowAction
    include CRUD::DestroyAction
    include CRUD::ChangeLogSupport

    protected

    def permitted_attributes
      super.permit(:label, :url, :linkable_type, :linkable_id)
    end
  end
end
