require_relative 'logged_task'

class TaskStorage

  def initialize
    @task_list = {}
  end

  private def active_task
    raise NoActiveTaskError if @active_task.nil?
    @active_task
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
      name = active_task
    else
      if name != @active_task
        set_pause time, true unless @active_task.nil?
        set_active_task name
      end
    end
    puts "task '#{name}' unpaused" if @task_list[name].last_paused?
    @task_list[name] << TimeMark.new(time, false)
    puts "added track mark on task '#{name}' at: #{time}"
  end

  def set_pause time, is_paused
    if @task_list[active_task].last_paused? && is_paused
      puts "task '#{active_task}' already paused"
      return
    end
    @task_list[active_task] << TimeMark.new(time, is_paused)
    puts "task '#{active_task}' #{is_paused ? 'paused' : 'unpaused'}"
  end

  def puts_total_time name
    name = active_task if name.nil?
    duration = @task_list[name].total_time
    puts "total time of task '#{name}': #{duration} hours"
  end

  def puts_current_period_duration
    duration = @task_list[active_task].current_period_duration
    puts "last period duration of task '#{active_task}': #{duration} hours"
  end
end