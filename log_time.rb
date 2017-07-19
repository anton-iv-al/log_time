require 'thor'
require 'logger'
require_relative 'exceptions'
require_relative 'storage_file'

$logger = Logger.new('time_marks.log', 10, 1024 * 1024)
$storage_file = StorageFile.new('time_marks.yml')

class LogTimeCLI < Thor
  desc "track [TASK_NAME]", "Add track mark on current time to certain task. Default task - current."
  def track name = nil
    $storage_file.modify{|storage|
      storage.puts_current_period_duration
      storage.add_time_mark(name, Time.now)
      $logger.info "track #{name}"
    }
  end

  desc "pause", "Pause current task."
  def pause
    $storage_file.modify{|storage|
      storage.puts_current_period_duration
      storage.set_pause(Time.now, true)
      $logger.info "pause"
    }
  end

  desc "unpause", "Unpause current task."
  def unpause
    $storage_file.modify{|storage|
      storage.set_pause(Time.now, false)
      $logger.info "unpause"
    }
  end

  desc "total [TASK_NAME]", "Show time, spent to certain task. Default task - current."
  def total name = nil
    $storage_file.modify{|storage|
      storage.puts_total_time(name)
      $storage_file.need_to_save = false
    }
  end

  desc "list [MAX_LINES]", "Show tasks list. Default max lines - unlimited"
  def list max_lines = -1
    $storage_file.modify{|storage|
      storage.puts_task_list(max_lines.to_i)
      $storage_file.need_to_save = false
    }
  end

  desc "marks [TASK_NAME] [MAX_LINES]", "Show track marks list of certain task. Default: task - current, max lines - unlimited."
  def marks *params
    max_lines = params.find{|p| !(/^\d+$/ =~ p).nil?}
    name = params.find{|p| (/^\d+$/ =~ p).nil?}
    raise(ArgsError) if params.length != [name, max_lines].find_all{|p| !p.nil?}.length
    $storage_file.modify{|storage|
      storage.puts_task_marks_list(name, max_lines.to_i)
      $storage_file.need_to_save = false
    }
  end
end


begin
  puts "***"
  LogTimeCLI.start(ARGV)
rescue StorageParseError
  puts "can't parse YAML from storage file"
rescue StorageWriteError
  puts "can't write YAML to storage file"
rescue ArgsError
  puts "wrong format of command args"
rescue TaskNotFoundError => err
  puts "not found task: '#{err}'"
end