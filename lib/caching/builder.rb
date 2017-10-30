class Caching::Builder
  include M3::Delayable

  def perform
    remove_future_builders
    Person.update_score_count
    Competition.update_discipline_score_count
    Caching::HTMLPreLoader.perform_now
  end

  private

  def remove_future_builders
    same_future_jobs.each(&:delete)
  end
end
