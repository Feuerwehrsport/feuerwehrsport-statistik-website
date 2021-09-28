# frozen_string_literal: true

# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

base_command = '/usr/local/bin/<%= Rails.application.class.name.deconstantize.underscore %>.'
job_type :ensure_delayed_job_running, ':path/m3/etc/ensure_delayed_job_running.sh :task'
job_type :ensure_unicorn_running, ':path/m3/etc/ensure_unicorn_running.sh :task'

every :reboot do
  ensure_delayed_job_running '<%= Rails.application.class.name.deconstantize.underscore %>'
  ensure_unicorn_running '<%= Rails.application.class.name.deconstantize.underscore %>'
end

every :day, at: '1:10 am' do
  command "#{base_command}rake m3:failed_delayed_jobs"
end

every 5.minutes do
  ensure_delayed_job_running '<%= Rails.application.class.name.deconstantize.underscore %>'
  ensure_unicorn_running '<%= Rails.application.class.name.deconstantize.underscore %>'
end

# every :day, at: '2:42 am' do
#   command "#{base_command}rake backup_dump"
# end
