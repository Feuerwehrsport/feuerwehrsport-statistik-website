class ChangeLogsController < ResourceController
  resource_actions :index, cache: :index

  def show
    redirect_to action: :index
  end

  protected

  def find_collection
    super.reorder(created_at: :desc).limit(1000)
  end
end
