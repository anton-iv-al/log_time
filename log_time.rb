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

  desc "list [MAX_LINES]", ""
  def list max_lines = -1
    StorageFile.new.modify{|storage|
      storage.puts_task_list(max_lines.to_i)
      $logger.info "list"
    }
  end

  desc "marks [TASK_NAME] [MAX_LINES]", ""
  def marks *params
    max_lines = params.find{|p| !(/^\d+$/ =~ p).nil?}
    name = params.find{|p| (/^\d+$/ =~ p).nil?}
    raise(ArgsError) if params.length != [name, max_lines].find_all{|p| !p.nil?}.length
    StorageFile.new.modify{|storage|
      storage.puts_task_marks_list(name, max_lines.to_i)
      $logger.info "marks"
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
rescue StorageParseError
  puts "can't parse YAML from storage file"
  puts_not_saved
rescue StorageWriteError
  puts "can't write YAML to storage file"
  puts_not_saved
rescue NoActiveTaskError
  puts "need active task"
  puts_not_saved
rescue ArgsError
  puts "wrong format of command args"
rescue TaskNotFoundError => err
  puts "not found task: '#{err}'"
rescue
  puts_not_saved
end