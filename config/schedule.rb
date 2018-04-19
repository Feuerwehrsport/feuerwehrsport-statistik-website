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
base_command = '/usr/bin/feuerwehrsport-statistik.'
job_type :ensure_delayed_job_running, ':path/etc/ensure_delayed_job_running.sh :task'
job_type :ensure_unicorn_running, ':path/etc/ensure_unicorn_running.sh :task'
job_type :dump, ':path/etc/store_dump.sh "--exclude-table-data=$(sed \':a;N;$!ba;s/\n/ --exclude-table-data=/g\' :path/config/dump_exclude_tables)" :task'

every :reboot do
  ensure_delayed_job_running 'feuerwehrsport-statistik'
  ensure_unicorn_running 'feuerwehrsport-statistik'
end

every :day, at: '5:12 am' do
  command "#{base_command}rake m3:log_file_parser"
end

every :day, at: '3:42 am' do
  dump 'feuerwehrsport-statistik'
end

every 5.minutes do
  ensure_delayed_job_running 'feuerwehrsport-statistik'
  ensure_unicorn_running 'feuerwehrsport-statistik'
end
