require_relative 'logged_task'

class TaskStorage
  def initialize
    @task_list = {}
  end

  def[] name
    @task_list[name]
  end

  def new_task name
    @task_list[name] = LoggedTask.new
  end
end