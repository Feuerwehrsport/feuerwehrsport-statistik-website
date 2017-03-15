class Backend::CompetitionsController < Backend::ResourcesController
  protected

  def permitted_attributes
    super.permit(:name, :date, :place_id, :event_id, :score_type_id, :hint_content)
  end
end