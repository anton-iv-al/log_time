require 'thor'
require 'logger'
require_relative 'exceptions'
require_relative 'storage_file'

$logger = Logger.new('time_marks.log', 10, 1024 * 1024)
$storage_file = StorageFile.new('time_marks.yml')

class LogTimeCLI < Thor
  desc "track [TASK_NAME]", ""
  def track name = nil
    $storage_file.modify{|storage|
      begin
        storage.puts_current_period_duration
      rescue NoActiveTaskError
      end
      storage.add_time_mark(name, Time.now)
      $logger.info "track #{name}"
    }
  end

  desc "pause", ""
  def pause
    $storage_file.modify{|storage|
      storage.puts_current_period_duration
      storage.set_pause(Time.now, true)
      $logger.info "pause"
    }
  end

  desc "unpause", ""
  def unpause
    $storage_file.modify{|storage|
      storage.set_pause(Time.now, false)
      $logger.info "unpause"
    }
  end

  desc "total [TASK_NAME]", ""
  def total name = nil
    $storage_file.modify{|storage|
      storage.puts_total_time(name)
      $logger.info "total #{name}"
      $storage_file.need_to_save = false
    }
  end

  desc "list [MAX_LINES]", ""
  def list max_lines = -1
    $storage_file.modify{|storage|
      storage.puts_task_list(max_lines.to_i)
      $logger.info "list"
      $storage_file.need_to_save = false
    }
  end

  desc "marks [TASK_NAME] [MAX_LINES]", ""
  def marks *params
    max_lines = params.find{|p| !(/^\d+$/ =~ p).nil?}
    name = params.find{|p| (/^\d+$/ =~ p).nil?}
    raise(ArgsError) if params.length != [name, max_lines].find_all{|p| !p.nil?}.length
    $storage_file.modify{|storage|
      storage.puts_task_marks_list(name, max_lines.to_i)
      $logger.info "marks"
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
rescue NoActiveTaskError
  puts "need active task"
rescue ArgsError
  puts "wrong format of command args"
rescue TaskNotFoundError => err
  puts "not found task: '#{err}'"
end