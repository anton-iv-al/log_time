require 'yaml'
require_relative 'task_storage'

class StorageFile
  def initialize dir = 'time_marks.yml'
    @dir = dir
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
    begin
      File.open(@dir, 'w'){|file|
        file.puts YAML.dump(storage)
      }
    rescue
      raise StorageWriteError
    end
  end

  def modify
    storage = read
    yield storage
    write storage
  end
end