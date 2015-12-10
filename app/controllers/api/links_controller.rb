module API
  class LinksController < BaseController
    include CRUD::CreateAction

    protected

    def permitted_attributes
      super.permit(:label, :url, :linkable_type, :linkable_id)
    end
  end
end
