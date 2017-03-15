class Backend::NationsController < Backend::ResourcesController
  protected

  def permitted_attributes
    super.permit(:name, :iso)
  end
end