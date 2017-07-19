class StorageParseError < RuntimeError
end

class StorageWriteError < RuntimeError
end

class NoActiveTaskError < RuntimeError
end

class ArgsError < RuntimeError
end

class TaskNotFoundError < RuntimeError
end