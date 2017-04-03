class BlueprintApi < ErrorsApi
  require 'yajl'
  require '/opt/engines/lib/ruby/api/system/container_state_files.rb'
  def save_blueprint(blueprint, container)
    # return log_error_mesg('Cannot save incorrect format',blueprint) unless blueprint.is_a?(Hash)
    SystemDebug.debug(SystemDebug.builder, blueprint.class.name)
    state_dir = ContainerStateFiles.container_state_dir(container)
    Dir.mkdir(state_dir) if File.directory?(state_dir) == false
    statefile = state_dir + '/blueprint.json'
    f = File.new(statefile, File::CREAT | File::TRUNC | File::RDWR, 0644)
    f.write(blueprint.to_json)
    f.close
    true
  end
 
  def self.load_blueprint_file(blueprint_file_name)
    blueprint_file = File.open(blueprint_file_name, 'r')
   # json_hash = deal_with_json(blueprint_file.read)
    parser = Yajl::Parser.new
    json_hash = parser.parse(blueprint_file.read)
    blueprint_file.close
    json_hash
  end

  def load_blueprint(container)
    state_dir = ContainerStateFiles.container_state_dir(container)
    raise EnginesException.new(error_hash('No Statedir', container.container_name)) unless File.directory?(state_dir)
    statefile = state_dir + '/blueprint.json'
    raise EnginesException.new(error_hash("No Blueprint File Found", statefile)) unless File.exist?(statefile)
    BlueprintApi.load_blueprint_file(statefile)
  end
end
