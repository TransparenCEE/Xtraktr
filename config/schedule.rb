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
#env :PATH, '/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin'
set :output, "log/cron.log"

# remove old records from filemapper
every :day, :at => '4:00 am' do
  rake "filemapper:clean"
end

# make sure all datasets have download data files
every :hour do
  rake "generate_files:download_data_files"
end

# check if someone has requested a dataset to have it download files generated
every 2.minutes do
  rake "generate_files:force_download_data_files"
end


# send notifications
every 30.minutes do
  runner "NotificationTrigger.process_all_types"
end
