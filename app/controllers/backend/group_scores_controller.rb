module Backend
  class GroupScoresController < ResourcesController
    protected

    def permitted_attributes
      super.permit(:team_id, :team_number, :gender, :time, :group_score_category_id, :run)
    end
  end
end