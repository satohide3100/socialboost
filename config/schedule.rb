require File.expand_path(File.dirname(__FILE__) + "/environment")
set :output, 'log/cron.log'
set :environment, :production

every 1.minute do
  rake "main:fav"
end

every 3.minutes do
  rake "main:follow"
end
