class TaskTimeouts
  @@default_task_timeout =  20
  @@task_timeouts = {
    stop: 28,
    start: 32,
    restart: 60,
    recreate: 120,
    create: 120,
    build: 200,
    rebuild: 200,
    pause: 20,
    unpause: 20,
    destroy: 36,
    delete: 40,
    running: 40
  }

  def self.task_set_timeout(task)
    if @@task_timeouts.key?(task.to_sym)
      @@task_timeouts[task.to_sym]
    else
      @@default_task_timeout
    end
  end
end