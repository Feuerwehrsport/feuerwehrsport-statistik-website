class ChangeLogsController < ResourceController
  cache_actions :index

  def show
    redirect_to action: :index
  end

  def index
    @change_logs = ChangeLog.free_access.order(created_at: :desc).decorate.first(1000)
  end
end
