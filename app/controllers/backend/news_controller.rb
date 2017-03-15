class Backend::NewsController < Backend::ResourcesController
  protected

  def permitted_attributes
    super.permit(:title, :admin_user_id, :content, :published_at)
  end
end