#require '/opt/engines/lib/ruby/containers/ManagedContainer.rb'
require 'objspace'

class ManagedService < ManagedContainer
  @ctype='system_service'
  #  @consumers=Hash.new

  def ctype
    return @ctype
  end

  def initialize(name,memory,hostname,domain_name,image,volumes,port,eports,dbs,environments,framework,runtime)
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
    @last_result=''
    @setState='nocontainer'
    @databases=dbs
    
    @framework=framework
    @runtime=runtime
    @persistant=false  #Persistant means neither service or engine need to be up/running or even exist for this service to exist
  end
  attr_reader :persistant,:type_path,:publisher_namespace

  def get_service_hash(service_hash)

    if service_hash.is_a?(Hash) == false
      log_error_mesg('Get service hash  recevied a ' + service_hash.class.name,service_hash.to_s)
      #service_hash = create_service_hash(service_hash) #WTF
    end
    return service_hash
  end

  def add_consumer(object)
    service_hash = get_service_hash(object)
    if service_hash == nil
      log_error_mesg('add consumer passed nil service_hash ','')
      return false
    end
    service_hash[:persistant] =@persistant
    if is_running? ==true   || @persistant == true
      if service_hash[:fresh] == false
        result = true
      else
        result = add_consumer_to_service(service_hash)
      end
    end
    #note we add to service regardless of whether the consumer is already registered
    #for a reason
    if result != true
      return result
    end
    save_state
    return result
  end

  def pull_image
    # if has repo field prepend repo
    # if has no / then local image
    # return false
    #
    if @repository.nil? == false 
      return @core_api.pull_image(@repository + '/' + image)
    elsif image.include?('/')
      return @core_api.pull_image(image)
    end
    return false
  end
  
  def run_configurator(configurator_params)
    if is_running? == false
      log_error_mesg('service not running ',configurator_params)
      return false
    end
    if check_cont_uid == false
      log_error_mesg('service missing cont_userid ',configurator_params)
      return false
    end
    cmd = 'docker exec -u ' + @cont_userid.to_s + ' ' +  @container_name.to_s + ' /home/configurators/set_' + configurator_params[:configurator_name].to_s + '.sh \'' + SystemUtils.service_hash_variables_as_str(configurator_params).to_s + '\''
    result = SystemUtils.execute_command(cmd)
#    if result[:result] == 0
#      return true
#    end
#    return false
    return result
  end

  def retrieve_configurator(configurator_params)
    if is_running? == false
      log_error_mesg('service not running ',configurator_params)
      return false
    end
    if check_cont_uid == false
      log_error_mesg('service missing cont_userid ',configurator_params)
      return false
    end
    cmd = 'docker exec -u ' + @cont_userid + ' ' +  @container_name + ' /home/configurators/read_' + configurator_params[:configurator_name].to_s + '.sh '
    result = SystemUtils.execute_command(cmd)
    if result[:result] == 0
      variables = SystemUtils.hash_string_to_hash(result[:stdout])
      configurator_params[:variables] = variables
      return configurator_params
    end
    log_error_mesg('Failed retrieve_configurator',result)
    return Hash.new
  end

  def remove_consumer(service_hash)
    service_hash = get_service_hash(service_hash)
    if service_hash == nil
      log_error_mesg('remove consumer nil service hash ','')
      return false
    end
    if is_running? != true
      log_error_mesg('Cannot remove consumer if Service is not running ',service_hash)
      return false
    end
    if check_cont_uid == false
      log_error_mesg('service missing cont_userid ',service_hash)
      return false
    end
    if @persistant == true
      if  service_hash.has_key?(:remove_all_data)  && service_hash[:remove_all_data] == true
        p :removing_consumer
        result = rm_consumer_from_service(service_hash)
      end
    end
    return result
  end

  def service_manager
    return @core_api.loadServiceManager()
  end

  def create_service()
    SystemUtils.run_command('/opt/engines/scripts/setup_service_dir.sh ' +container_name)
    envs = @core_api.load_and_attach_persistant_services(self)
    shared_envs = @core_api.load_and_attach_shared_services(self)
    if shared_envs.is_a?(Array)
      if envs.is_a?(Array) == false
        envs = shared_envs
      else
        envs.concat(shared_envs)
      end
    end
    if envs.is_a?(Array) == true
      if@environments.is_a?(Array) == true
        SystemUtils.debug_output( :envs, @environments)
        @environments.concat(envs)
        @environments.uniq! #FIXME as new values dont replace old only duplicates values
      else
        @environments = envs
      end
    end
    @setState='running'
    if create_container() == true
      #start with configurations
      #save haere are below call inspect
      save_state()
      service_configurations = service_manager.get_service_configurations_hashes(@container_name)
      if service_configurations.is_a?(Array)
        service_configurations.each do |configuration|
          run_configurator(configuration)
        end
      end
      register_with_dns()
      p :service_non_persis
      @core_api.load_and_attach_nonpersistant_services(self)
      p :register_non_persis
      @core_api.register_non_persistant_services(self)
      reregister_consumers()
      return true
    else
      save_state()
      log_error_mesg('Failed to create service',self)
      return false
    end
  end

  def recreate
    if  destroy_container() ==true
      if   create_service()==true
        return true
      else
        log_error_mesg('Failed to create service in recreate',self)
        @setState='running'
        save_state()
        return false
      end
    else
      log_error_mesg('Failed to destroy service in recreate',self)
      @setState='running'
      save_state()
      return false
    end
  end

  def registered_consumers
    params = Hash.new()
    params[:publisher_namespace] = @publisher_namespace
    params[:type_path] = @type_path
    return   @core_api.get_registered_against_service(params)
  end

  def reregister_consumers
    if @persistant == true
      p :no_reregister_persistant
      return true
    end
    if is_running? == false
      log_error_mesg('Cant register consumers as not running ',self)
      return false
    end
    registered_hashes = registered_consumers
    if registered_hashes == nil
      return
    end
    registered_hashes.each do |service_hash|
      if service_hash[:persistant] == false
        add_consumer_to_service(service_hash)
      end
    end
    return true
  end

  def destroy
    log_error_mesg('Cannot call destroy on a service',self)
    return false
  end

  def deleteimage
    log_error_mesg('Cannot call deleteimage on a service',self)
    return false
    #noop never do  this as need buildimage again or only for expert
  end

 
  
  private 
  def set_container_pid
     @pid ='-1'
   end
  def   add_consumer_to_service(service_hash)
      if is_running? == false
        log_error_mesg('service not running ',service_hash)
        return false
      end
      if check_cont_uid == false
        log_error_mesg('service missing cont_userid ',service_hash)
        return false
      end
      cmd = 'docker exec -u ' + @cont_userid.to_s + ' ' + @container_name.to_s  + ' /home/add_service.sh ' + SystemUtils.service_hash_variables_as_str(service_hash)
      result = SystemUtils.execute_command(cmd)
      if result[:result] == 0
        return true
      end
      log_error_mesg('Failed add_consumer_to_service',result)
      return false
      #return  SystemUtils.run_system(cmd)
    end
  
    def check_cont_uid
      if @cont_userid == nil || @cont_userid == false
        @cont_userid = running_user
        if @cont_userid == nil || @cont_userid == false
          log_error_mesg('service missing cont_userid ',@container_name)
          return false
        end
      end
      return true
    end
  
    def   rm_consumer_from_service(service_hash)
      if is_running? == false
        log_error_mesg('service not running ',service_hash)
        return false
      end
      if check_cont_uid == false
        log_error_mesg('No uid service not running ',service_hash)
        return false
      end
      cmd = 'docker exec -u ' + @cont_userid + ' ' +  @container_name + ' /home/rm_service.sh \'' + SystemUtils.service_hash_variables_as_str(service_hash) + '\''
      result = SystemUtils.execute_command(cmd)
      if result[:result] == 0
        return true
      end
      log_error_mesg('Failed rm_consumer_from_service',result)
      return false
      #return  SystemUtils.run_system(cmd)
    end


  #Sets @last_error to msg + object.to_s (truncated to 256 chars)
  #Calls SystemUtils.log_error_msg(msg,object) to log the error
  #@return none
  def self.log_error_mesg(msg,object)
    obj_str = object.to_s.slice(0,512)
    SystemUtils.log_error_mesg(msg,object)
  end
end
