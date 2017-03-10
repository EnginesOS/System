module AvailableServices

  require_relative 'service_manager_access.rb'
  require '/opt/engines/lib/ruby/managed_services/system_services/volume_service.rb'

 

  def load_avail_services_for_type(typename)
    avail_services = {}
    avail_services[:persistent] = []
    avail_services[:non_persistent] = []  
    dir = SystemConfig.ServiceMapTemplateDir + '/' + typename
    STDERR.puts('looking at  ' + dir  )
    if Dir.exist?(dir)
      Dir.foreach(dir) do |service_dir_entry|
        begin       
          if service_dir_entry.start_with?('.') == true
            next
          end
          if service_dir_entry.end_with?('.yaml')
            service = load_service_definition(dir + '/' + service_dir_entry)
            STDERR.puts('looking at  ' + dir + '/' + service_dir_entry )
            if service.nil? == false
              if service.is_a?(String)
                log_error_mesg('service yaml load error', service)
              else
                service = SoftwareServiceDefinition.summary(service)
                if service[:persistent] == true
                  avail_services[:persistent].push(service)
                else
                  avail_services[:non_persistent].push(service)
                end

              end
            end
          end
        rescue StandardError => e
          log_exception(e, dir.to_s + '/' + service_dir_entry)
          next
        end
      end
    end
    #p :avail_services
    #p avail_services.to_s
    return avail_services
  rescue StandardError => e
    log_exception(e)
  end

#  def load_avail_services_for(typename)
#    avail_services = []
#    dir = SystemConfig.ServiceMapTemplateDir + '/' + typename
#    if Dir.exists?(dir)
#      Dir.foreach(dir) do |service_dir_entry|
#        begin
#          next if service_dir_entry.start_with?('.')
#          if service_dir_entry.end_with?('.yaml')
#            service = load_service_definition(dir + '/' + service_dir_entry)
#            avail_services.push(service.to_h) if !service.nil?
#          end
#        rescue StandardError => e
#          log_exception(e)
#          next
#        end
#      end
#    end
#    return avail_services
#  rescue StandardError => e
#    log_exception(e)
#  end

#  def load_avail_component_services_for(engine)
#    retval = {}    
#    if engine.is_a?(ManagedEngine)
#      retval['self']= load_avail_services_for_type(ManagedEngine)
#      params = {}
#      params[:engine_name] = engine.container_name
#      persistent_services = get_engine_persistent_services(params)
#      return persistent_services if persistent_services.is_a?(EnginesError)
#      persistent_services.each do |service|
#        type_key = service[:publisher_namespace] + '/' + service[:type_path]
#          next if retval.key?(type_key)
#        retval[type_key] = load_avail_services_for_type(service[:type_path])
#      end
#    else
#      p :load_avail_component_services_for_engine_got_a
#      p engine.to_s
#      return EnginesCoreError.new('No Availble components', :warning)
#    end
#    return retval
#  rescue StandardError => e
#    log_exception(e)
#  end

  def list_attached_services_for(objectName, identifier)
    service_manager.list_attached_services_for(objectName, identifier)
  rescue StandardError => e
    log_exception(e)
  end

#  def list_avail_services_for(object)
#    objectname = object.class.name.split('::').last
#    services = load_avail_services_for(objectname)
#    subservices = load_avail_component_services_for(object)
#    retval = {}
#    retval[:services] = services
#    retval[:subservices] = subservices
#    return retval
#  rescue StandardError => e
#    log_exception(e)
#  end
def load_service_definition(filename)
#open soft link not actual
   yaml_file = File.open(filename)
  s = SoftwareServiceDefinition.from_yaml(yaml_file)
  yaml_file.close
  s
 rescue StandardError => e
   log_exception(e)
 end
 
  def load_software_service(params)
    params[:service_container_name]  = ServiceDefinitions.get_software_service_container_name(params)
    return params[:service_container_name]  if params[:service_container_name].is_a?(EnginesError)

    loadManagedService(params[:service_container_name] )
  rescue StandardError => e
    log_exception(e)
  end
end