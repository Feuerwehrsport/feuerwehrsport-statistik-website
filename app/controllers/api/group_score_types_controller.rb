module API
  class GroupScoreTypesController < BaseController
    include CRUD::IndexAction

    protected
    
    def base_collection
      super_collection = super
      super_collection = super_collection.where(discipline: params[:discipline]) if params[:discipline].present?
      super_collection
    end
  end
end
