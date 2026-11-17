# frozen_string_literal: true

# competition the results are imported into (backend imports and import requests), remembered in the session
module Backend::ImportCompetitionSelection
  extend ActiveSupport::Concern

  SESSION_KEY = :import_competition_id

  included do
    helper_method :import_competition, :import_competitions
  end

  private

  def import_competition
    return @import_competition if defined?(@import_competition)

    session[SESSION_KEY] = params[:competition_id].presence if params.key?(:competition_id)
    @import_competition = Competition.find_by(id: session[SESSION_KEY])&.decorate
  end

  # sorted by date or the latest created first ("Letzter")
  def import_competitions
    order = params[:order] == 'sorted' ? { date: :desc } : { id: :desc }
    Competition.includes(:place, :event).reorder(order).decorate
  end
end
