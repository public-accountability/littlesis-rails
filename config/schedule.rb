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

every 1.minute do
	rake "users:create_from_new_profiles", output: nil
  rake "search:update_entity_delta_index", output: nil
end

every 1.day do
  rake "sessions:clear_expired", output: nil
end

every 1.day, at: '5:00 am' do
  rake "ts:rebuild", output: nil
end