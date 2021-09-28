# frozen_string_literal: true

namespace :m3 do
  desc 'notify about failed delayed jobs'
  task failed_delayed_jobs: :environment do
    failed_jobs = Delayed::Job.where.not(failed_at: nil)
    if failed_jobs.present?
      puts "Some delayed jobs failed on #{`hostname`}"
      p failed_jobs
    end
  end

  desc 'drop ; create ; migrate ; seed'
  task :reseed do
    `rake db:drop && rake db:create && rake db:migrate && rake db:seed`
  end
end
