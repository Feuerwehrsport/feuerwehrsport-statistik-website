class ChangeLogsController < ResourceController
  cache_actions :index

  def index
    @change_logs = ChangeLog.free_access.decorate.last(1000)
  end
end
