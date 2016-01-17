module API
  class GroupScoreTypesController < BaseController
    include CRUD::CreateAction
    include CRUD::IndexAction
    include CRUD::ChangeLogSupport

    protected

    def create_permitted_attributes
      permitted_attributes.permit(:name, :discipline)
    end
    
    def base_collection
      super_collection = super
      super_collection = super_collection.where(discipline: params[:discipline]) if params[:discipline].present?
      super_collection
    end
  end
end
