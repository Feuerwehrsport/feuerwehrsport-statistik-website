module Backend
  class PersonParticipationsController < ResourcesController
    protected

    def permitted_attributes
      super.permit(:person_id, :group_score_id)
    end
  end
end