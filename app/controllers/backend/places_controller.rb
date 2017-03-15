class Backend::PlacesController < Backend::ResourcesController
  protected

  def permitted_attributes
    super.permit(:name, :latitude, :longitude)
  end
end