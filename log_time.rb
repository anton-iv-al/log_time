require 'thor'
require_relative 'LoggedTask'
require_relative 'TimeMark'

class LogTimeCLI < Thor
  desc "time", "current time"
  def time()
    now = Time.now
    puts now
    task = LoggedTask.new 'test'
    task << now
    task << now + hour_to_sec(5.4)
    puts task.total_time
  end
end

LogTimeCLI.start(ARGV)