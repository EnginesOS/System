class TaskTimeouts
  @@default_task_timeout =  20
  @@task_timeouts = {}
  @@task_timeouts[:stop]= 28
  @@task_timeouts[:start]= 32
  @@task_timeouts[:restart]= 60
  @@task_timeouts[:recreate]= 120
  @@task_timeouts[:create]= 120
  @@task_timeouts[:build]= 200
  @@task_timeouts[:rebuild]= 200
  @@task_timeouts[:pause]= 20
  @@task_timeouts[:unpause]= 20
  @@task_timeouts[:destroy]= 36
  @@task_timeouts[:delete]= 40
  @@task_timeouts[:running]= 40
        
  def self.task_set_timeout(task)

    return  @@default_task_timeout  unless @@task_timeouts.key?(task.to_sym)
    #  SystemDebug.debug(SystemDebug.engine_tasks, :timeout_set_for_task,task.to_sym, @task_timeouts[task.to_sym].to_s + 'secs')
    # return  @default_task_timeout
     @@task_timeouts[task.to_sym]
  end
end