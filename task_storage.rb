require_relative 'logged_task'

class TaskStorage
  def initialize
    @task_list = {}
  end

  def name_valid? name
    if !(/^\d+$/ =~ name).nil?
      puts "task name can't consist of only digits"
      return false
    end
    return true
  end

  def new_task name
    @task_list[name] = LoggedTask.new
    puts "created new task: '#{name}'"
  end

  def set_active_task name
    new_task(name) unless @task_list[name]
    @active_task = name
    puts "active task switched to: '#{name}'"
  end

  def add_time_mark name, time
    if name.nil?
      if @active_task.nil?
        puts "no tasks exists, need to specify task name"
        return false
      end
      name = @active_task
    else
      if name != @active_task
        set_pause(time, true) unless @active_task.nil?
        set_active_task name
      end
    end

    set_pause(time, false)
    puts "added track mark on task '#{name}' at: #{time}"
    return true
  end

  def set_pause time, is_paused
    if @active_task.nil?
      puts "no tasks exists"
      return false
    end
    if @task_list[@active_task].last_paused? && is_paused
      puts "task '#{@active_task}' already paused"
      return false
    end
    @task_list[@active_task] << TimeMark.new(time, is_paused)
    puts "task '#{@active_task}' #{is_paused ? 'paused' : 'unpaused'}"
    puts "task '#{@active_task}' #{is_paused ? 'paused' : 'unpaused'}"
    return true
  end

  def puts_total_time name
    return if (name = prepare_name(name)).nil?
    duration = @task_list[name].total_time
    puts "total time of task '#{name}': #{duration} hours"
  end

  def puts_current_period_duration
    return if @active_task.nil?
    duration = @task_list[@active_task].current_period_duration(false)
    puts "last period duration of task '#{@active_task}': #{duration} hours"
  end

  def puts_task_list max_lines
    names = @task_list.keys
    if names.empty?
      puts "no tasks"
      return
    end

    max_name_length = names.inject(0){|max, n| n.length > max ? n.length : max}
    spaces_for_max = 4

    names.delete(@active_task)
    puts "active task:"
    puts_task(@active_task, spaces_for_max + max_name_length - @active_task.length)
    puts @task_list[@active_task].last_paused? ? "paused" : "unpaused"

    puts "***"
    puts "rest:"
    names.sort_by!{|n| @task_list[n].last_mark_time}.reverse!
    names = names.first(max_lines) if max_lines > 0

    names.each{|n| puts_task(n, spaces_for_max + max_name_length - n.length)}
  end

  def puts_task name, spaces_count = 4
    puts "[task]:#{name}"+ '.'*spaces_count + "[last track]:#{@task_list[name].last_mark_time}"
  end

  def puts_task_marks_list name, max_lines
    return if (name = prepare_name(name)).nil?

    max_lines = -1 if max_lines.nil?
    raise(TaskNotFoundError, name) if @task_list[name].nil?

    puts "task: '#{name}'"
    @task_list[name].puts_marks_list max_lines
  end

  def prepare_name name
    if name.nil?
      if @active_task.nil?
        puts "no tasks exists"
        return nil
      end
      return @active_task
    end
    return name
  end
end