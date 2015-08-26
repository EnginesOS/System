class ContainerApi
  def initialize(docker_api,system_api,engines_core)
   @docker_api = docker_api
   @system_api = system_api
   @engines_core = engines_core
    
 end
 
  def web_sites(container)
    @engines_core.web_sites_for(container)
  end
  
   def get_container_memory_stats(container)
     test_system_api_result(@system_api.get_container_memory_stats(container))
   end
 
   def get_container_network_metrics(container)
     test_system_api_result(@system_api.get_container_network_metrics(container))
   end
   
   def unpause_container(container)
      clear_error
      test_docker_api_result(@docker_api.unpause_container(container))
    end
    
   def pause_container(container)
      clear_error
      test_docker_api_result(@docker_api.pause_container(container))
    end    
 
   def inspect_container(container)
     clear_error
     test_docker_api_result(@docker_api.inspect_container(container))
   end
 
   def stop_container(container)
     clear_error
     test_docker_api_result(@docker_api.stop_container(container))
   end
 
   def ps_container(container)
     test_docker_api_result(@docker_api.ps_container(container))
   end
 
   def logs_container(container)
     clear_error
     test_docker_api_result(@docker_api.logs_container(container))
   end
   
   def start_container(container)
     clear_error
     @engines_core.start_dependancies(container) if container.dependant_on.is_a?(Array)
     test_docker_api_result(@docker_api.start_container(container))
   end
    
   def save_container(container)
     test_system_api_result(@system_api.save_container(container))
   end
 
   def test_docker_api_result(result)
     @last_error = @docker_api.last_error if result.nil? || result == false
     return result
   end
   
   def delete_image(container)
     clear_error
     return  test_system_api_result(@system_api.delete_container_configs(container)) if test_docker_api_result(@docker_api.delete_image(container))
     # only delete if del all otherwise backup
     #N O Image well delete the rest
     test_system_api_result(@system_api.delete_container_configs(container)) if !test_docker_api_result(@docker_api.image_exist?(container.image))
       p 'delete_imatge'
     return true
   rescue StandardError => e
     log_exception(e)
   end
   
   def destroy_container(container)
     clear_error
     if container.has_container?
       ret_val = test_docker_api_result(@docker_api.destroy_container(container))
     else
       ret_val = true
     end
     if ret_val
       ret_val = test_docker_api_result(@system_api.destroy_container(container))  #removes cid file
     end
     return ret_val
   rescue StandardError => e
     container.last_error = 'Failed To Destroy ' + e.to_s
     log_exception(e)
   end
   
   def is_startup_complete(container)
      clear_error
      return test_system_api_result(@system_api.is_startup_complete(container))
    rescue StandardError => e
      log_exception(e)
    end
    
   def create_container(container)
     clear_error
     return log_error_mesg('Failed To create container exists by the same name', container) if container.ctype != 'system_service' && container.has_container?
     test_system_api_result(@system_api.clear_cid_file(container))
     test_system_api_result(@system_api.clear_container_var_run(container))
     @engines_core.start_dependancies(container) if container.dependant_on.is_a?(Array)
     container.pull_image if container.ctype != 'container'
     return test_system_api_result(@system_api.create_container(container)) if test_docker_api_result(@docker_api.create_container(container))
     return false
   rescue Exception => e
     container.last_error = ('Failed To Create ' + e.to_s)
     log_exception(e)
   end
   

  def save_blueprint(blueprint,container)
    test_system_api_result(@system_api.save_blueprint(blueprint,container))
  end

  def load_blueprint(container)
    test_system_api_result(@system_api.load_blueprint(container))
  end

   
   
   private
  def clear_error
      @last_error = ''
    end
    

  def log_error_mesg(msg,object)
    obj_str = object.to_s.slice(0, 256)
    @last_error = @last_error.to_s + ':' + msg +':' + obj_str
    SystemUtils.log_error_mesg(msg, object)
  end

  def log_exception(e)
    @last_error = @last_error.to_s + e.to_s
    p @last_error + e.backtrace.to_s
    return false
  end

  def test_system_api_result(result)
    @last_error = @system_api.last_error.to_s if result.nil? || result == false
    return result
  end

  def check_system_api_result(result)
    @last_error = @system_api.last_error.to_s[0, 128] if result.nil? || result == false
    return result
  end
 end