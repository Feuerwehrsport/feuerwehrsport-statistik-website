Delayed::Worker.destroy_failed_jobs = false
Delayed::Worker.sleep_delay = 60
Delayed::Worker.max_attempts = 1
Delayed::Worker.max_run_time = 30.minutes
Delayed::Worker.read_ahead = 1
Delayed::Worker.default_queue_name = 'default'
Delayed::Worker.delay_jobs = !(Rails.env.test? || Rails.env.development?)
