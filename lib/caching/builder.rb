module Caching
  class Builder
    include Delayed::Helper

    def perform
      remove_future_builders
      HTMLPreLoader.perform_now
    end

    private

    def remove_future_builders
      same_future_jobs.each do |job|
        job.delete
      end
    end
  end
end