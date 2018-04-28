module Containers
  # @param container_log file
  # @param retentioncount
  def rotate_container_log(container_id, retention = 10)
    run_server_script('rotate_container_log', container_id.to_s + ' ' + retention.to_s)
  end

  def save_container(container)

    # FIXME:
    #    api = container.container_api.dup
    #    container.container_api = nil
    #    last_result = container.last_result
    #    #  last_error = container.last_error
    #    # save_last_result_and_error(container)
    #    container.last_result = ''

    #synchronise ?
    serialized_object = YAML.dump(container)
    state_dir = container_state_dir(container)
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
    cache_engine(container, ts) unless cache_update_ts(container, ts)
    STDERR.puts('saved ' + container.container_name + ':' + caller[1].to_s + ':' + caller[2].to_s)
    true
  rescue StandardError => e
    unlock_container_conf_file(state_dir)
    container.last_error = last_error unless container.nil?
    # FIXME: Need to rename back if failure
    SystemUtils.log_exception(e)
  ensure
      unlock_container_conf_file(state_dir)    
  end

  def is_startup_complete?(container)
    File.exist?(container_state_dir(container) + '/run/flags/startup_complete')
  end

  def write_actionators(container, actionators)
    unless actionators.nil?
      Dir.mkdir_p(actionator_dir(container)) unless Dir.exist?(actionator_dir(container))
      serialized_object = YAML.dump(actionators)

      f = File.new(actionator_dir(container) + '/actionators.yaml', File::CREAT | File::TRUNC | File::RDWR, 0644)
      f.puts(serialized_object)
      f.flush()
      f.close
    end
  end

  def get_service_actionator(container, action)
    actionators = load_service_actionators(container)
    # STDERR.puts(' ACITONATORS ' + actionators.to_s)
    STDERR.puts('LOOKING 4 ' + action.to_s)
    STDERR.puts('is it ' + actionators[action.to_sym].to_s)
    actionators[action.to_sym]
  end

  def load_service_actionators(container)
    #    SystemDebug.debug(SystemDebug.actions, container, actionator_dir(container) + '/actionators.yaml')
    #    if File.exist?(actionator_dir(container) + '/actionators.yaml')
    #      yaml = File.read(actionator_dir(container) + '/actionators.yaml')
    #      actionators = YAML::load(yaml)
    #      SystemDebug.debug(SystemDebug.actions, container, actionators)
    #      actionators if actionators.is_a?(Hash)
    #    else
    #      {}
    #    end
    SoftwareServiceDefinition.actionators({
      type_path: container.type_path, publisher_namespace: container. publisher_namespace })
  end

  def get_engine_actionator(container, action)
    actionators = load_engine_actionators(container)
    SystemDebug.debug(SystemDebug.actions, container, actionators[action]) #.to_sym])
    #  STDERR.puts('ACRTION ' + action.to_s)
    actionators[action]
  end

  def load_engine_actionators(container)
    SystemDebug.debug(SystemDebug.actions, container, actionator_dir(container) + '/actionators.yaml')
    if File.exist?(actionator_dir(container) + '/actionators.yaml')
      yaml = File.read(actionator_dir(container) + '/actionators.yaml')
      actionators = YAML::load(yaml)
      SystemDebug.debug(SystemDebug.actions,container ,actionators)
      actionators if actionators.is_a?(Hash)
    else
      {}
    end
  end

end