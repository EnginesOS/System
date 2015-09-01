class BlueprintApi < ErrorsApi
  
  def save_blueprint(blueprint, container)
    clear_error
    p :Blueprint_isa
    p blueprint.class.name
   # return log_error_mesg('Cannot save incorrect format',blueprint) unless blueprint.is_a?(Hash)     
    puts blueprint.class.name
    state_dir = ContainerStateFiles.container_state_dir(container)
    Dir.mkdir(state_dir) if File.directory?(state_dir) == false
    statefile = state_dir + '/blueprint.json'
    f = File.new(statefile, File::CREAT | File::TRUNC | File::RDWR, 0644)
    f.write(blueprint.to_json)
    f.close
    return true
  rescue StandardError => e
    log_error_mesg('Blueprint save Failure', container)
    log_exception(e)
  end

  
  def self.load_blueprint_file(blueprint_file_name)
    blueprint_file = File.open(blueprint_file_name, 'r')
    json_hash = JSON.parse(blueprint_file.read)
    blueprint_file.close
    p json_hash
    SystemUtils.symbolize_keys(json_hash)
  end
  
  def load_blueprint(container)
    clear_error
    state_dir = ContainerStateFiles.container_state_dir(container)
    return log_error_mesg('No Statedir', container) unless File.directory?(state_dir)
    statefile = state_dir + '/blueprint.json'
   return log_error_mesg("No Blueprint File Found", statefile) unless File.exist?(statefile)
    BlueprintApi.load_blueprint_file(statefile)
  rescue StandardError => e
    log_error_mesg('Blueprint Parse Failure', blueprint)
    log_exception(e)
  end  
end
