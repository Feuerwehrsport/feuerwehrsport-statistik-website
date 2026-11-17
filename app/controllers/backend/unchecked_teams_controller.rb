# frozen_string_literal: true

class Backend::UncheckedTeamsController < Backend::BackendController
  include ChangeLogging

  backend_actions

  default_form do |f|
    f.input :name
    f.input :shortcut
    f.input :status, as: :radio_buttons, collection: { 'Team' => 'team', 'Feuerwehr' => 'fire_station' }
    f.input :checked_at, html5: true
  end

  default_index do |t|
    t.col :name
  end

  def show_associations?
    false
  end

  # merges the unchecked team into a similar team; always: future imports replace the name automatically
  def merge
    team = Team.find(params[:id])
    correct_team = Team.find(params[:correct_team_id])
    authorize!(:merge, team)
    authorize!(:merge, correct_team)

    Team.transaction do
      log_change(correct_team, serializer: TeamSerializer, action: 'merge',
                               before_hash: serialize_for_log(team, TeamSerializer))
      EntityMerge.merge!(team, correct_team, always: params[:always].present?)
    end
    clean_cache
    redirect_to backend_unchecked_teams_path, notice: "#{team.name} wurde mit #{correct_team.name} zusammengeführt."
  rescue ActiveRecord::ActiveRecordError => e
    redirect_to backend_unchecked_team_path(team), alert: "Konnte nicht zusammengeführt werden: #{e.message}"
  end

  protected

  def after_update
    if form_resource.checked_at.present?
      redirect_to collection_redirect_url
    else
      super
    end
  end
end
