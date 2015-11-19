require 'open-uri'

module Caching
  class HTMLPreLoader
    include Delayed::Helper
    include Rails.application.routes.url_helpers

    def perform
      urls.each do |url|
        open("http://localhost:5060#{url}").read rescue nil
      end
    end

    def urls
      urls = [
        competitions_path,
        people_path,
        places_path,
        teams_path,
        years_path,
        events_path,
        series_rounds_path,
      ]
      urls += Competition.order(created_at: :desc).pluck(:id).map { |id| competition_path(id) }
      urls += Person.order(created_at: :desc).pluck(:id).map { |id| person_path(id) }
      urls += Place.order(created_at: :desc).pluck(:id).map { |id| place_path(id) }
      urls += Team.order(created_at: :desc).pluck(:id).map { |id| team_path(id) }
      urls += Year.pluck(:year).map { |id| year_path(id) }
      urls += Event.order(created_at: :desc).pluck(:id).map { |id| event_path(id) }
      urls += Series::Round.order(created_at: :desc).pluck(:id).map { |id| series_round_path(id) }
      urls += Series::PersonAssessment.order(created_at: :desc).pluck(:id).map { |id| series_assessment_path(id) }
    end
  end
end