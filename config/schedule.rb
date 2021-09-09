# Use this file to easily define all of your cron jobs.

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

log_file = '/var/www/littlesis/log/cron.log'

every 1.day do
  runner "WebRequest.nullify_identifying_data", output: log_file
end

every 1.day, at: '3:30 am' do
  rake "maps:screenshot:recent", output: log_file
end

every 1.day, at: '4:30 am' do
  rake "entities:update_link_counts", output: log_file
end

every 1.day, at: '5:00 am' do
  rake "maps:screenshot:missing", output: log_file
end
