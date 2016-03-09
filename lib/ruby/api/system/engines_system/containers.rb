module Containers
  @@lock_timeout  = 2
  # FIXME: Kludge should read from network namespace /proc ?
  def get_container_network_metrics(container_name)
    ret_val = {}
    clear_error

    def error_result
      ret_val = {}
      ret_val[:in] = 'n/a'
      ret_val[:out] = 'n/a'
      return ret_val
    end
    commandargs = 'docker exec ' + container_name + " netstat  --interfaces -e |  grep bytes |head -1 | awk '{ print $2 \" \" $6}'  2>&1"

    result = SystemUtils.execute_command(commandargs)
    if result[:result] != 0
      ret_val = error_result
    else
      res = result[:stdout]
      vals = res.split('bytes:')
      if vals.count > 2
        if vals[1].nil? == false && vals[2].nil? == false
          ret_val[:in] = vals[1].chop
          ret_val[:out] = vals[2].chop
        else
          ret_val = error_result
        end
      else
        ret_val = error_result
      end
      return ret_val
    end
  rescue StandardError => e
    log_exception(e)
    return error_result
  end

  def save_container(cont)
    clear_error
    # FIXME:
    container = cont.dup
    api = container.container_api.dup
    container.container_api = nil
    last_result = container.last_result
    #  last_error = container.last_error
    # save_last_result_and_error(container)
    container.last_result = ''

    serialized_object = YAML.dump(container)
    container.container_api = api
    # container.last_result = last_result
    #container.last_error = last_error
    state_dir = ContainerStateFiles.container_state_dir(container)
    FileUtils.mkdir_p(state_dir)  if Dir.exist?(state_dir) == false
    statefile = state_dir + '/running.yaml'
    # BACKUP Current file with rename
    log_error_mesg('container locked', container.container_name) unless lock_container_conf_file(state_dir)
    if File.exist?(statefile)
      statefile_bak = statefile + '.bak'
      File.rename(statefile, statefile_bak)
    end
    f = File.new(statefile, File::CREAT | File::TRUNC | File::RDWR, 0644)
    f.puts(serialized_object)
    f.flush()
    f.close
    begin
    ts =  File.mtime(statefile)
    rescue StandardError => e
      ts = Time.now
    end
    unlock_container_conf_file(state_dir)
    cache_engine( container, ts) unless cache_update_ts(container, ts)
    
    return true
  
  rescue StandardError => e
    unlock_container_conf_file(state_dir)
    container.last_error = last_error
    # FIXME: Need to rename back if failure
    SystemUtils.log_exception(e)
    ensure
        unlock_container_conf_file(state_dir)
  end

  
  def unlock_container_conf_file(state_dir)
    File.delete(state_dir + '/lock') if  File.exists?(state_dir + '/lock')
  end
  
 def is_container_conf_file_locked?(state_dir)
   lock_fn = state_dir + '/lock'
   return false unless  File.exists?(lock_fn) 
         loop = 0 
         while  File.exists?(lock_fn)
           sleep(0.2)
           loop != 1
           return true if loop > 5  
         end    
 end
 
  def lock_container_conf_file(state_dir)
    lock_fn = state_dir + '/lock'
    if  File.exists?(lock_fn) && lock_has_expired(lock_fn) == false
      loop = 0 

      while  File.exists?(lock_fn)
        sleep(0.2)
        loop += 1
        if loop > 10
          pid = File.read(lock_fn)
          log_error_mesg("cleared lock in ",state_dir,' pid ',pid)
          File.delete(lock_fn)
          break
        end
      end
    else    
     lock = File.new(lock_fn, File::CREAT | File::TRUNC | File::RDWR, 0644)
      lock.puts(Process.pid.to_s)
      lock.close()
      return true
    
    end
    rescue StandardError => e
    log_error_mesg('locking exception', lock_fn,e)
          return true
  end
  def is_startup_complete(container)
    clear_error
    return File.exist?(ContainerStateFiles.container_state_dir(container) + '/run/flags/startup_complete')
  rescue StandardError => e
    SystemUtils.log_exception(e)
  end

  def lock_has_expired(lock_fn)
    return true if File.mtime(lock_fn) <  Time.now + @@lock_timeout
    return false
    rescue StandardError => e
      return true
  end

  
def write_actionators(container, actionators)
  return true if actionators.nil?
  Dir.mkdir_p(ContainerStateFiles.actionator_dir(container)) unless Dir.exist?(ContainerStateFiles.actionator_dir(container))
  serialized_object = YAML.dump(actionators)
  
  f = File.new(ContainerStateFiles.actionator_dir(container) + '/actionators.yaml', File::CREAT | File::TRUNC | File::RDWR, 0644)
      f.puts(serialized_object)
      f.flush()
      f.close
rescue StandardError => e
  log_exception(e)
end

def load_engine_actionators(container)
  SystemDebug.debug(SystemDebug.actions,container,ContainerStateFiles.actionator_dir(container) + '/actionators.yaml')
  return [] unless File.exist?(ContainerStateFiles.actionator_dir(container) + '/actionators.yaml')
    yaml =  File.read(ContainerStateFiles.actionator_dir(container) + '/actionators.yaml')
  actionators = YAML::load(yaml)
  SystemDebug.debug(SystemDebug.actions,container,actionators)
  return actionators if actionators.is_a?(Hash)    
    return []
  rescue StandardError => e
    log_exception(e)  
end
  
end