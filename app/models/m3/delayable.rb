# frozen_string_literal: true

module M3::Delayable
  extend ActiveSupport::Concern

  class_methods do
    def enqueue(*arguments)
      enqueue_with_options({}, *arguments)
    end

    def enqueue_with_options(options, *arguments)
      options = default_options.merge(options)
      options[:run_at] = @run_at.call if @run_at.present?
      Delayed::Job.enqueue new(*arguments), options
    end

    def default_options
      {
        priority: @priority || 0,
        run_at: nil,
      }
    end

    def priority(priority)
      @priority = priority
    end

    def run_at(&block)
      @run_at = block
    end

    def perform_now(*arguments)
      new(*arguments).perform
    end
  end

  protected

  def same_future_jobs
    Delayed::Job.where(locked_at: nil, failed_at: nil).select { |job| job.payload_object.is_a?(self.class) }
  end
end
