Delayed::Worker.logger = Logger.new(File.join(Rails.root, 'log', 'delayed_job.log'))
max_run_time = 500
