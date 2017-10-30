class API::CompetitionsController < API::BaseController
  api_actions :create, :show, :index, :update, change_log: true,
                                               create_form: %i[name place_id event_id date],
                                               update_form: %i[name score_type_id]

  protected

  def resource_show_object
    ExtendedCompetitionSerializer.new(resource.decorate)
  end
end
