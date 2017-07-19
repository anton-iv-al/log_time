require 'yaml'
require_relative 'task_storage'

class StorageFile
  attr_accessor :need_to_save

  def initialize dir
    @dir = dir
    @need_to_save = true
  end

  private def read
    if FileTest::exists?(@dir)
      begin
        YAML.load(IO.read(@dir))
      rescue
        raise StorageParseError
      end
    else
      TaskStorage.new
    end
  end

  private def write storage
    unless @need_to_save
      @need_to_save = true
      return
    end

    begin
      File.open(@dir, 'w'){|file|
        file.puts YAML.dump(storage)
      }
      puts_saved
    rescue
      puts_not_saved
      raise StorageWriteError
    end
  end

  def modify
    storage = read
    yield storage
    write storage
  end

  private def puts_saved
    puts "***"
    puts "changes saved"
  end

  private def puts_not_saved
    puts "***"
    puts "changes not saved"
  end
end