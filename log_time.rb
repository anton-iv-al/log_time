require 'thor'
require 'logger'
require_relative 'exceptions'
require_relative 'storage_file'

$logger = Logger.new('time_marks.log', 10, 100)

class LogTimeCLI < Thor
  desc "time", "current time"
  def time()
    now = Time.now
    puts now
    StorageFile.new('time_marks.yml').modify{|storage|
      task = storage.new_task 'test'
      task << now
      task << now + hour_to_sec(5.4)
      puts task.total_time
      task1 = storage.new_task 'test1'
      task1 << now + hour_to_sec(15.8)
    }
  end
end

begin
  LogTimeCLI.start(ARGV)
rescue StorageParseError => err
  puts err
rescue StorageWriteError => err
  puts err
end