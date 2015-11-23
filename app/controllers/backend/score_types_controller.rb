module Backend
  class ScoreTypesController < ResourcesController
    protected

    def permitted_attributes
      super.permit(:people, :run, :score)
    end
  end
end