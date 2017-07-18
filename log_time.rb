require 'thor'
require_relative 'task_storage'

require 'yaml'

class LogTimeCLI < Thor
  desc "time", "current time"
  def time()
    now = Time.now
    puts now
    storage = TaskStorage.new
    task = storage.new_task 'test'
    task << now
    task << now + hour_to_sec(5.4)
    puts task.total_time
    task1 = storage.new_task 'test1'
    task1 << now + hour_to_sec(15.8)
    puts YAML.dump(storage)
  end
end

LogTimeCLI.start(ARGV)