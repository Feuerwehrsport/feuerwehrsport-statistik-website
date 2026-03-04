# frozen_string_literal: true

class Caching::Builder < ApplicationJob
  limits_concurrency key: :caching, group: :caching

  def perform
    return if same_future_jobs.present?

    Person.update_score_count
    Competition.update_discipline_score_count
    Team.update_members_and_competitions_count
    Caching::HtmlPreLoader.perform_later
  end
end
