require 'thor'
require 'logger'
require_relative 'exceptions'
require_relative 'storage_file'

$logger = Logger.new('time_marks.log', 10, 1024 * 1024)

class LogTimeCLI < Thor
  desc "track [TASK_NAME]", ""
  def track name = nil
    StorageFile.new.modify{|storage|
      begin
        storage.puts_current_period_duration
      rescue NoActiveTaskError
      end
      storage.add_time_mark(name, Time.now)
      $logger.info "track #{name}"
    }
    puts_saved
  end

  desc "pause", ""
  def pause
    StorageFile.new.modify{|storage|
      storage.puts_current_period_duration
      storage.set_pause(Time.now, true)
      $logger.info "pause"
    }
    puts_saved
  end

  desc "unpause", ""
  def unpause
    StorageFile.new.modify{|storage|
      storage.set_pause(Time.now, false)
      $logger.info "unpause"
    }
    puts_saved
  end

  desc "total [TASK_NAME]", ""
  def total name = nil
    StorageFile.new.modify{|storage|
      storage.puts_total_time(name)
      $logger.info "total #{name}"
    }
  end
end



def puts_saved
  puts "***"
  puts "changes saved"
end

def puts_not_saved
  puts "***"
  puts "changes not saved"
end



begin
  puts "***"
  LogTimeCLI.start(ARGV)
rescue StorageParseError => err
  puts err
  puts_not_saved
rescue StorageWriteError => err
  puts err
  puts_not_saved
rescue NoActiveTaskError
  puts "need active task"
  puts_not_saved
rescue
  puts_not_saved
end