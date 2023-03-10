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
job_type :dump, ':path/etc/store_dump.sh "--exclude-table-data=$(sed \':a;N;$!ba;s/\n/ --exclude-table-data=/g\' ' \
                ':path/config/dump_exclude_tables)" :task'

every 20.minutes do
  rails_command 'debug:failed_delayed_jobs'
  rails_command 'rails_log_parser:parse[22]'
end

every :day, at: '3:42 am' do
  dump 'feuerwehrsport-statistik'
end
