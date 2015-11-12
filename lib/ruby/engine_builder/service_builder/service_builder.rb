require_relative '../../service_manager/service_definitions.rb'
class ServiceBuilder < ErrorsApi
  
  attr_reader :volumes,:app_is_persistant
  
  require_relative 'orphan_services.rb'
  include Orphans
  
  require_relative 'roll_back.rb'
  include RollBack
  require_relative 'service_checks.rb'
  include ServiceChecks
    
  def initialize(service_manager, templater, engine_name, attached_services)
    @engine_name = engine_name
    @service_manager = service_manager
    @templater = templater
    @attached_services =  attached_services 
    @volumes = {}
    @orphans = []
    @app_is_persistant = false
      p @engine_name 
  end
    
  def create_non_persistant_services(services)  
  services.each do |service_hash|
    service_def = get_service_def(service_hash)
    return log_error_mesg('Failed to load service definition for ', service_hash) if service_def.nil?
    next if service_def[:persistant]
    service_hash = ServiceDefinitions.set_top_level_service_params(service_hash, @engine_name)
    return log_error_mesg('Failed to Attach ', service_hash) unless @service_manager.add_service(service_hash)
    @attached_services.push(service_hash)
  end
  return true
end

def create_persistant_services(services, environ, use_existing)
   services.each do |service_hash|
     service_def = get_service_def(service_hash)
     return log_error_mesg('no matching service definition',self) if service_def.nil?
     if service_def[:persistant]    
       service_hash[:persistant] = true
        return false unless process_persistant_service(service_hash, environ, use_existing)       
     end
   end
  return true
 end

 def process_persistant_service(service_hash, environ, use_existing)  
   service_hash = ServiceDefinitions.set_top_level_service_params(service_hash, @engine_name)   
     return log_error_mesg("Problem with service hash", service_hash) if service_hash.is_a?(FalseClass)
        existing = match_service_to_existing(service_hash, use_existing) 
        if existing.is_a?(Hash)
          service_hash = existing
          service_hash[:shared] = true
          @first_build = false
        #  LAREADY DONE service_hash = use_orphan(service_hash) if @service_manager.match_orphan_service(service_hash) == true
        elsif @service_manager.match_orphan_service(service_hash) == true #auto orphan pick up
          service_hash = use_orphan(service_hash)
          @first_build = false
        elsif @service_manager.service_is_registered?(service_hash) == false
          @first_build = true
          service_hash[:fresh] = true
        else # elseif over attach to existing true attached to existing
          service_hash[:fresh] = false
          return log_error_mesg('Failed to build cannot over write ' + service_hash[:service_handle].to_s + ' Service Found', self)
        end
       
   if service_hash[:type_path] == 'filesystem/local/filesystem'
     result = add_file_service(service_hash) 
         return log_error_mesg('failed to create fs',self) unless result                
   end 
        p :attach_service
        p service_hash
        @templater.fill_in_dynamic_vars(service_hash)
         environ.concat(SoftwareServiceDefinition.service_environments(service_hash))
        p :with_env
        p service_hash
        # FIXME: release orphan should happen latter unless use reoprhan on rebuild failure
        if @service_manager.add_service(service_hash)
          @attached_services.push(service_hash)              
        else
          return log_error_mesg('Failed to attach ' + @service_manager.last_error, service_hash)
        end
        return true
 end
 
 def match_service_to_existing(service_hash, use_existing)
   return false if use_existing.nil?

   use_existing.each do |existing_service|
     p :create_type
      p existing_service[:create_type]
     next if existing_service[:create_type] == 'new'
     p existing_service[:type_path] + " and " + service_hash[:type_path]
     p existing_service[:publisher_namespace] + " and " + service_hash[:publisher_namespace]
     if existing_service[:publisher_namespace] == service_hash[:publisher_namespace]\
       && existing_service[:type_path] == service_hash[:type_path]
         p :comparing
         # FIX ME run a check here on service hash
         return use_active_service(service_hash, existing_service) if existing_service[:create_type] == 'active'
         return use_orphan(existing_service) if existing_service[:create_type] == 'orphan'        
     end
  end  
   log_error_mesg('Failed to Match Service to attach', service_hash)
 end
 
 def use_active_service(service_hash, existing_service )
  s = @service_manager.get_service_entry(existing_service)
  p :usering_active_Serviec

  s[:variables][:engine_path] = service_hash[:variables][:engine_path] if service_hash[:type_path] == 'filesystem/local/filesystem'
  s[:fresh] = false
  s[:shared] = true
   p s 
  return s
 end
 
 
 
  def get_service_def(service_hash)
    p service_hash[:type_path]
    p service_hash[:publisher_namespace]
    return SoftwareServiceDefinition.find(service_hash[:type_path], service_hash[:publisher_namespace])
  end


  def run_volume_builder(container,username)
    clear_error
    if File.exist?(SystemConfig.CidDir + '/volbuilder.cid')
      command = 'docker stop volbuilder'
      SystemUtils.run_system(command)
      command = 'docker rm volbuilder'
      SystemUtils.run_system(command)
      File.delete(SystemConfig.CidDir + '/volbuilder.cid')
    end
    mapped_vols = get_volbuild_volmaps container
    command = 'docker run --name volbuilder --memory=12m -e fw_user=' + username + ' -e data_gid=' + container.data_gid + '   --cidfile ' +SystemConfig.CidDir + 'volbuilder.cid ' + mapped_vols + ' -t engines/volbuilder:' + SystemUtils.system_release + ' /bin/sh /home/setup_vols.sh '
    SystemUtils.debug_output('Run volume builder',command)
    p command
    #run_system(command)
    result = SystemUtils.execute_command(command)
    if result[:result] != 0
      p result[:stdout]
      @last_error='Volbuilder: ' + command + '->' + result[:stdout].to_s + ' err:' + result[:stderr].to_s
      p @last_error
      return false
    end
    #Note no -d so process will not return until setup.sh completes
    command = 'docker rm volbuilder'
    File.delete(SystemConfig.CidDir + '/volbuilder.cid') if File.exist?(SystemConfig.CidDir + '/volbuilder.cid')
    res = SystemUtils.run_system(command)
    SystemUtils.log_error(res) if res.is_a?(FalseClass)
    # don't return false as
    return true
  rescue StandardError => e
    log_exception(e)
  end
  
  def add_file_service(service_hash) 
    p 'Add File Service ' + service_hash[:variables][:name].to_s
    #log_build_output('Add File Service ' + name)
    service_hash[:variables][:engine_path] = service_hash[:variables][:service_name] if service_hash[:variables][:engine_path].nil? || service_hash[:variables][:engine_path] == ''
    if service_hash[:variables][:engine_path] == '/home/app/' || service_hash[:variables][:engine_path]  == '/home/app' 
      @app_is_persistant = true   
      service_hash[:variables][:service_name]='app'
      service_hash[:variables][:engine_path] = '/home/app/'
    else
      service_hash[:variables][:engine_path] = '/home/fs/' + service_hash[:variables][:engine_path] unless service_hash[:variables][:engine_path].start_with?('/home/fs/') ||service_hash[:variables][:engine_path].start_with?('/home/app')  
    end
    service_hash[:variables][:volume_src] = SystemConfig.LocalFSVolHome + '/' + service_hash[:parent_engine].to_s  + '/' + service_hash[:variables][:service_name].to_s unless service_hash[:variables].key?(:volume_src)
    
    service_hash[:variables][:volume_src].strip!
    service_hash[:variables][:volume_src] = SystemConfig.LocalFSVolHome + '/' + service_hash[:parent_engine]  + '/' + service_hash[:variables][:volume_src] unless service_hash[:variables][:volume_src].start_with?(SystemConfig.LocalFSVolHome)
       
    permissions = PermissionRights.new(service_hash[:parent_engine] , '', '')
    vol = Volume.new(service_hash[:variables][:service_name], service_hash[:variables][:volume_src], service_hash[:variables][:engine_path], 'rw', permissions)
    @volumes[service_hash[:variables][:service_name]] = vol
    return true
  rescue StandardError => e
    SystemUtils.log_exception(e)
  end
  protected
def get_volbuild_volmaps(container)
    clear_error
    state_dir = SystemConfig.RunDir + '/containers/' + container.container_name + '/run/'
    log_dir = SystemConfig.SystemLogRoot + '/containers/' + container.container_name
    volume_option = ' -v ' + state_dir + ':/client/state:rw '
    volume_option += ' -v ' + log_dir + ':/client/log:rw '
    unless container.volumes.nil?
      container.volumes.each_value do |vol|
        SystemUtils.debug_output('build vol maps', vol)
        volume_option += ' -v ' + vol.localpath.to_s + ':/dest/fs:rw'
      end
    end
    volume_option += ' --volumes-from ' + container.container_name
    return volume_option
  rescue StandardError => e
    log_exception(e)
  end
end
