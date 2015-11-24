module Backend
  class GroupScoreTypesController < ResourcesController
    protected

    def permitted_attributes
      super.permit(:regular, :name, :discipline)
    end
  end
end