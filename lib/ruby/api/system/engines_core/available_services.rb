module AvailableServices

  require_relative 'service_manager_access.rb'
  require '/opt/engines/lib/ruby/managed_services/system_services/volume_service.rb'

  def load_service_definition(filename)

    yaml_file = File.open(filename)
    SoftwareServiceDefinition.from_yaml(yaml_file)
  rescue StandardError => e
    p :filename
    p filename
    log_exception(e)
  end

  def load_avail_services_for_type(typename)
    avail_services = []
    dir = SystemConfig.ServiceMapTemplateDir + '/' + typename
    if Dir.exist?(dir)
      Dir.foreach(dir) do |service_dir_entry|
        begin
          if service_dir_entry.start_with?('.') == true
            next
          end
          if service_dir_entry.end_with?('.yaml')
            service = load_service_definition(dir + '/' + service_dir_entry)
            if service.nil? == false
              if service.is_a?(String)
                log_error_mesg('service yaml load error', service)
              else
                avail_services.push(service.to_h)
              end
            end
          end
        rescue StandardError => e
          log_exception(e)
          puts dir.to_s + '/' + service_dir_entry
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

  def load_avail_services_for(typename)
    avail_services = []
    dir = SystemConfig.ServiceMapTemplateDir + '/' + typename
    if Dir.exists?(dir)
      Dir.foreach(dir) do |service_dir_entry|
        begin
          next if service_dir_entry.start_with?('.')
          if service_dir_entry.end_with?('.yaml')
            service = load_service_definition(dir + '/' + service_dir_entry)
            avail_services.push(service.to_h) if !service.nil?
          end
        rescue StandardError => e
          log_exception(e)
          next
        end
      end
    end
    return avail_services
  rescue StandardError => e
    log_exception(e)
  end

  def load_avail_component_services_for(engine)
    retval = {}
    if engine.is_a?(ManagedEngine)
      params = {}
      params[:engine_name] = engine.container_name
      persistent_services = get_engine_persistent_services(params)
      return nil if persistent_services.is_a?(FalseClass)
      persistent_services.each do |service|
        type_path = service[:type_path]
        retval[type_path] = load_avail_services_for_type(type_path)
      end
    else
      p :load_avail_component_services_for_engine_got_a
      p engine.to_s
      return nil
    end
    return retval
  rescue StandardError => e
    log_exception(e)
    return nil
  end

  def list_attached_services_for(objectName, identifier)
    check_sm_result(service_manager.list_attached_services_for(objectName, identifier))
  rescue StandardError => e
    log_exception(e)
  end

  def list_avail_services_for(object)
    objectname = object.class.name.split('::').last
    services = load_avail_services_for(objectname)
    subservices = load_avail_component_services_for(object)
    retval = {}
    retval[:services] = services
    retval[:subservices] = subservices
    return retval
  rescue StandardError => e
    log_exception(e)
  end

  def load_software_service(params)
    service_container = check_sm_result(ServiceDefinitions.get_software_service_container_name(params))
    params[:service_container_name] = service_container
    loadManagedService(service_container)
  rescue StandardError => e
    log_exception(e)
  end
end