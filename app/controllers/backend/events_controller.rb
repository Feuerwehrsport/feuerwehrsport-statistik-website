class Backend::EventsController < Backend::ResourcesController
  protected

  def permitted_attributes
    super.permit(:name)
  end
end