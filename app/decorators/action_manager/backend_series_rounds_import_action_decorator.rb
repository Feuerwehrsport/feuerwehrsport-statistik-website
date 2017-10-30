class ActionManager::BackendSeriesRoundsImportActionDecorator < ActionManager::MemberActionDecorator
  def url
    h.new_backend_series_round_import_path(resource)
  end

  def link_to?
    h.can?(:create, Series::RoundImport)
  end
end
