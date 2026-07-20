# frozen_string_literal: true

class Caching::HeavyBuilder < ApplicationJob
  limits_concurrency key: :caching, group: :caching

  def perform
    Competition.update_long_names
    Person.update_best_scores
    Team.update_best_scores

    clean_same_future_jobs
  end
end
