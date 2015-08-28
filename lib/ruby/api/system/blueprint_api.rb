class BlueprintApi < ErrorsApi
  
  def save_blueprint(blueprint, container)
    clear_error
    return log_error_mesg('Cannot save incorrect format',blueprint) unless blueprint.is_a?(Hash)     
    puts blueprint.to_s
    state_dir = ContainerStateFiles.container_state_dir(container)
    Dir.mkdir(state_dir) if File.directory?(state_dir) == false
    statefile = state_dir + '/blueprint.json'
    f = File.new(statefile, File::CREAT | File::TRUNC | File::RDWR, 0644)
    f.write(blueprint.to_json)
    f.close
  rescue StandardError => e
    log_error_mesg('Blueprint save Failure', container)
    log_exception(e)
  end

  def load_blueprint(container)
    clear_error
    state_dir = ContainerStateFiles.container_state_dir(container)
    return log_error_mesg('No Statdir', container) unless File.directory?(state_dir)
    statefile = state_dir + '/blueprint.json'
   return log_error_mesg("No Blueprint File Found", statefile) unless File.exist?(statefile)
      f = File.new(statefile, 'r')
      blueprint = JSON.parse(f.read)
      f.close
    return blueprint
  rescue StandardError => e
    log_error_mesg('Blueprint Parse Failure', blueprint)
    log_exception(e)
  end  
end
