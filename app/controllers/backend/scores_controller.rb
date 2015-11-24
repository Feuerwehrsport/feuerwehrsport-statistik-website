module Backend
  class ScoresController < ResourcesController
    protected

    def permitted_attributes
      super.permit(:person_id, :team_id, :team_number, :time, :discipline, :competition_id)
    end
  end
end