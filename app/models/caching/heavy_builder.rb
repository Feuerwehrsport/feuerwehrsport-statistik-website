# frozen_string_literal: true

class Caching::HeavyBuilder
  include M3::Delayable

  def perform
    return if same_future_jobs.present?

    Competition.update_long_names
    Person.update_best_scores
  end
end
