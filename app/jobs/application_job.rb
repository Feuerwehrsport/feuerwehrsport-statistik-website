# frozen_string_literal: true

class ApplicationJob < ActiveJob::Base
  self.log_arguments = false

  def clean_same_future_jobs
    SolidQueue::Job.where(class_name: self.class.name, finished_at: nil)
                   .joins(:ready_execution).destroy_all
  end
end
