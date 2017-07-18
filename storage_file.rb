require 'yaml'
require_relative 'task_storage'

class StorageFile
  def initialize dir
    @dir = dir
  end

  private def read
    if FileTest::exists?(@dir)
      begin
        YAML.load(IO.read(@dir))
      rescue
        raise StorageParseError, "Can't parse YAML from storage file."
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
      raise StorageWriteError, "Can't write YAML to storage file."
    end
  end

  def modify
    storage = read
    yield storage
    write storage
  end
end