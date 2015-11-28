module Backend
  class NewsController < ResourcesController
    protected

    def permitted_attributes
      super.permit(:title, :admin_user_id, :content, :published_at)
    end
  end
end