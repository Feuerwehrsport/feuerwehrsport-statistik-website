module Backend
  class LinksController < ResourcesController
    protected

    def permitted_attributes
      super.permit(:label, :linkable_id, :linkable_type, :url)
    end
  end
end