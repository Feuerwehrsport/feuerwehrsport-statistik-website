# frozen_string_literal: true

namespace :debug do
  desc 'notify about failed delayed jobs'
  task failed_delayed_jobs: :environment do
    # remove jobs with not found records at serialization time
    Delayed::Job.where.not(failed_at: nil)
                .where("last_error like 'ActiveRecord::RecordNotFound%lib/delayed/psych_ext.rb:17:in `load_dj%'")
                .delete_all
    Delayed::Job.where.not(failed_at: nil)
                .where("last_error like 'Error while trying to deserialize arguments: Couldn''t find %" \
                       "`deserialize_global_id%'")
                .delete_all

    failed_jobs = Delayed::Job.where.not(failed_at: nil)
    if failed_jobs.present?
      failed_ids = failed_jobs.map(&:id).sort.to_json
      current_file = Rails.root.join("tmp/failed_delayed_jobs-#{Date.current}.json")

      next if File.file?(current_file) && File.read(current_file) == failed_ids

      File.write(current_file, failed_ids)

      puts "Some delayed jobs failed on #{`hostname`}"
      p failed_jobs
    end
  end
end
