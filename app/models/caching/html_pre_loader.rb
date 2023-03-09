# frozen_string_literal: true

class Caching::HTMLPreLoader
  include M3::Delayable
  include UrlSupport

  def perform
    return unless Rails.configuration.caching

    urls.each do |url|
      URI.parse(url).open.read
    rescue StandardError
      nil
    end
  end

  def urls
    urls = [
      root_url,
      change_logs_url,
      competitions_url,
      people_url,
      places_url,
      teams_url,
      years_url,
      events_url,
      series_rounds_url,
      best_of_url,
    ]
    urls += Place.reorder(created_at: :desc).pluck(:id).map { |id| place_url(id) }
    urls += Year.pluck(:year).map { |id| year_url(id.to_i) }
    urls += Year.pluck(:year).map { |id| best_performance_year_url(id.to_i) }
    urls += Year.pluck(:year).map { |id| best_scores_year_url(id.to_i) }
    urls + Event.reorder(created_at: :desc).pluck(:id).map { |id| event_url(id) }
  end
end
