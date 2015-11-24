module Backend
  class GroupScoreCategoriesController < ResourcesController
    protected

    def permitted_attributes
      super.permit(:name, :competition_id, :group_score_type_id)
    end
  end
end