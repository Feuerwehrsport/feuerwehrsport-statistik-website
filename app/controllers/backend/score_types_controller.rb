class Backend::ScoreTypesController < Backend::ResourcesController
  protected

  def permitted_attributes
    super.permit(:people, :run, :score)
  end
end