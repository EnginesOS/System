class ManagedEngine < ManagedContainer
  def initialize(build_params, runtime_params , core_api)
    @memory = build_params[:memory]
    @hostname = build_params[:host_name]
    @domain_name = build_params[:domain_name]
    @container_name = build_params[:engine_name]
    @repository  = build_params[:repository_url]
    @image  = build_params[:image]   
    @last_error = 'None'   
    @protocol = build_params[:http_protocol]
    @volumes = runtime_params.volumes,
    @eports = runtime_params.worker_ports,
    @environments = runtime_params.environments,
    @framework = runtime_params.framework,
    @runtime = runtime_params.runtime,
     
    @data_uid = runtime_params.data_uid,
    @data_gid =  runtime_params.data_gid,
    @deployment_type = runtime_params.deployment_type
      
    @web_port = build_params[:web_port]
    p :volumes
      p runtime_params.volumes
    @last_result = ''
       @setState = 'nocontainer'
    @container_api = core_api
 
    @ctype = 'container'
    @conf_self_start = true

    save_state # no running.yaml throws a no such container so save so others can use
 
  end

  attr_reader :plugins_path, :extract_plugins

  def lock_values
    @ctype = 'container' if @ctype.nil?
    @ctype.freeze
    super
  end
  
    def load_blueprint
      return false unless has_api?
      @container_api.load_blueprint(self)
    end
  
  def plugins_path
    return '/plugins/'
  end

  def extract_plugins
    false
  end
    
  def engine_persistant_services
    services = @container_api.engine_persistant_services(@container_name)
    retval = ''
    if services.is_a?(Array)
      services.each do |service|
        retval += ' ' + SystemUtils.service_hash_variables_as_str(service)
      end
    elsif services.is_a?(Hash)
      retval = SystemUtils.service_hash_variables_as_str(services)
    end
    return retval
  end

  def engine_attached_services
    return @container_api.engine_attached_services(@container_name)
  end
end
