module Backend
  class CompetitionsController < ResourcesController
    protected

    def permitted_attributes
      super.permit(:name, :date, :place_id, :event_id, :score_type_id)
    end
  end
end