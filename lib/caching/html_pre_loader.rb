require 'open-uri'

class Caching::HTMLPreLoader
  include Delayed::Helper
  include Rails.application.routes.url_helpers

  def perform
    if Rails.env.production?
      urls.each do |url|
        open("#{Rails.configuration.base_url}#{url}", read_timeout: 25).read rescue nil
      end
    end
  end

  def urls
    urls = [
      root_path,
      change_logs_path,
      competitions_path,
      people_path,
      places_path,
      teams_path,
      years_path,
      events_path,
      series_rounds_path,
      best_of_path,
    ]
    urls += Place.order(created_at: :desc).pluck(:id).map { |id| place_path(id) }
    urls += Year.pluck(:year).map { |id| year_path(id.to_i) }
    urls += Year.pluck(:year).map { |id| best_performance_year_path(id.to_i) }
    urls += Year.pluck(:year).map { |id| best_scores_year_path(id.to_i) }
    urls += Event.order(created_at: :desc).pluck(:id).map { |id| event_path(id) }
  end
end