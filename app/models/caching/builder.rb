# frozen_string_literal: true

class Caching::Builder < ApplicationJob
  limits_concurrency key: :caching, group: :caching

  def perform
    Person.update_score_count
    Competition.update_discipline_score_count
    Team.update_members_and_competitions_count
    Caching::HtmlPreLoader.perform_later

    clean_same_future_jobs
  end
end
