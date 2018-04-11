class API::Series::ParticipationsController < API::BaseController
  api_actions :create, :show, :index, :update, :destroy,
              change_log: true,
              create_form: %i[cup_id assessment_id type person_id team_id team_number rank points time],
              update_form: %i[assessment_id person_id team_id team_number rank points time]

  protected

  def build_resource
    klass = if params[:series_participation][:person_id].present?
              ::Series::PersonParticipation
            else
              ::Series::TeamParticipation
            end
    super.becomes(klass).tap { |r| r.type = klass }
  end
end
