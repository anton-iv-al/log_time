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

  private def set_active_task name
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
        set_pause time, true unless @active_task.nil?
        set_active_task name
      end
    end
    puts "task '#{name}' unpaused" if @task_list[name].last_paused?
    @task_list[name] << TimeMark.new(time, false)
    puts "added track mark on task '#{name}' at: #{time}"
    return true
  end

  def set_pause time, is_paused
    if @task_list[@active_task].last_paused? && is_paused
      puts "task '#{@active_task}' already paused"
      return
    end
    @task_list[@active_task] << TimeMark.new(time, is_paused)
    puts "task '#{@active_task}' #{is_paused ? 'paused' : 'unpaused'}"
  end

  def puts_total_time name
    name = @active_task if name.nil?
    duration = @task_list[name].total_time
    puts "total time of task '#{name}': #{duration} hours"
  end

  def puts_current_period_duration
    return if @active_task.nil?
    duration = @task_list[@active_task].current_period_duration
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

  private def puts_task name, spaces_count = 4
    puts "[task]:#{name}"+ '.'*spaces_count + "[last track]:#{@task_list[name].last_mark_time}"
  end

  def puts_task_marks_list name, max_lines
    if name.nil?
      if @active_task.nil?
        puts "no tasks exists, need to specify task name"
        return
      end
      name = @active_task
    end
    max_lines = -1 if max_lines.nil?
    raise(TaskNotFoundError, name) if @task_list[name].nil?

    puts "task: '#{name}'"
    @task_list[name].puts_marks_list max_lines
  end
end