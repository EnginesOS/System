module Containers
 
  
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



  

  def is_startup_complete(container)
    clear_error
    return File.exist?(ContainerStateFiles.container_state_dir(container) + '/run/flags/startup_complete')
  rescue StandardError => e
    SystemUtils.log_exception(e)
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
  
  def get_engine_actionator(container,action)
    
    actionators = load_engine_actionators(container)
    p :ACI
    p action
    p  actionators[action]
    return actionators[action]
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