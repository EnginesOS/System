class ManagedEngine < ManagedContainer
  def initialize(name,memory,hostname,domain_name,image,volumes,port,eports,repo,dbs,environments,framework,runtime,core_api,data_uid,data_gid,deployment_type)
    @last_error='None'
    @container_name=name
    @memory=memory
    @hostname=hostname
    @domain_name=domain_name
    @image=image
    @eports=eports
    @environments=environments
    @volumes=volumes
    @port=port
    @repository=repo
    @last_result=''
    @setState='nocontainer'
    @databases=dbs
    @framework=framework
    @runtime=runtime
    @core_api= core_api
    @deployment_type = deployment_type
    @ctype ='container'
    @conf_self_start=false
    @data_uid=data_uid
    @data_gid=data_gid
    save_state # no running.yaml throws a no such container so save so others can use
  end

  attr_reader :ctype, :plugins_path, :extract_plugins

  def plugins_path
    return '/plugins/'
  end

  def extract_plugins
    false
  end

  def engine_persistant_services
    services = @core_api.engine_persistant_services(@container_name)
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
    return @core_api.engine_attached_services(@container_name)
  end

end
