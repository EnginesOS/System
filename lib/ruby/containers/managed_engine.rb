class ManagedEngine < ManagedContainer
  require '/opt/engines/lib/ruby/containers/managed_container.rb'
  @conf_register_dns = true
  require_relative 'managed_engine/managed_engine_on_action.rb'
  include ManagedEngineOnAction
  
  def initialize(build_params, runtime_params, core_api)
    @container_mutex = Mutex.new
    @memory = build_params[:memory]
    @hostname = build_params[:host_name]
    @domain_name = build_params[:domain_name]
    @container_name = build_params[:engine_name]
    @repository  = build_params[:repository_url]
    @image  = build_params[:image]
    @last_error = 'None'
    @protocol = build_params[:http_protocol]
    @volumes = build_params[:volumes]
    @environments = runtime_params.environments
    @framework = runtime_params.framework
    @runtime = runtime_params.runtime
    @mapped_ports = build_params[:mapped_ports]
    @data_uid = build_params[:data_uid]
    @data_gid = build_params[:data_gid]
    @cont_user_id = build_params[:cont_user_id]
    @conf_register_dns = true
    @conf_zero_conf = true
    @deployment_type = runtime_params.deployment_type
    @host_network = false
    @web_port = build_params[:web_port]
    @web_root = runtime_params.web_root
    @last_result = ''
    @container_api = core_api
    @setState = 'running'
    @ctype = 'app'
    @conf_self_start = true
    @capabilities = runtime_params.capabilities
    @volume_service_builder = build_params[:service_builder]
    expire_engine_info
    STDERR.puts("\n cont_user_id:" + @cont_user_id.to_s)
    save_state # no running.yaml throws a no such container so save so others can use
  end

  attr_reader :plugins_path, :extract_plugins, :web_root, :cont_user_id, :data_uid, :data_gid

  def lock_values
    @ctype = 'app' if @ctype.nil?
    @ctype.freeze
    super
  end

  def restart_complete_install?
    restart_required?
  end



  def volume_service_builder=(is_built)
    #raise EnginesException,ew('Error alread run', :error) unless @volume_service_builder.nil?
    #   STDERR.puts(' SET @service_builder.run_volume_builder ' +  builder.to_s )
    @volume_service_builder = is_built
  end

  def load_blueprint
    @container_api.load_blueprint(self)
  end

  def plugins_path
    '/plugins/'
  end

  def extract_plugins
    false
  end

  def add_shared_volume(service_hash)
    volume_name = service_hash[:owner] + '_' + service_hash[:service_handle]
    @volumes[volume_name] = {
      volume_name: volume_name,
      localpath: service_hash[:variables][:volume_src],
      remotepath: service_hash[:variables][:engine_path],
      permissions: service_hash[:variables][:permissions],
      user: service_hash[:variables][:user],
      group: service_hash[:variables][:group]
    }
    save_state
  end

  def engine_attached_services
    @container_api.engine_attached_services(self)
  end

  def error_type_hash(mesg, params = nil)
    {error_mesg: mesg,
      system: :managed_engine,
      params: params }
  end
end
