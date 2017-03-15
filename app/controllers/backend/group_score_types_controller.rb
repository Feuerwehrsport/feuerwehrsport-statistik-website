class Backend::GroupScoreTypesController < Backend::ResourcesController
  protected

  def permitted_attributes
    super.permit(:regular, :name, :discipline)
  end
end