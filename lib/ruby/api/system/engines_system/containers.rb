module Containers
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

  def save_container(container)
    clear_error
    # FIXME:
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
    ts =  File.mtime(statefile)
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
    if  File.exists?(lock_fn)
      loop = 0 
      while  File.exists?(lock_fn)
        sleep(0.2)
        loop != 1
        return false if loop > 10  
      end
    else
     lock = File.new(lock_fn, File::CREAT | File::TRUNC | File::RDWR, 0644)
      lock.puts(Process.pid.to_s)
      lock.close()
      return true
    end
    
  end
  def is_startup_complete(container)
    clear_error
    return File.exist?(ContainerStateFiles.container_state_dir(container) + '/run/flags/startup_complete')
  rescue StandardError => e
    SystemUtils.log_exception(e)
  end

end