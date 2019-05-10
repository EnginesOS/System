module AvailableServices

  require_relative 'service_manager_access.rb'
  #  require '/opt/engines/lib/ruby/managed_services/system_services/volume_service.rb'
  require '/opt/engines/lib/ruby/managed_services/service_definitions/service_top_level.rb'

  def load_avail_services_for_type(typename)
    avail_services = {
      persistent: [],
      non_persistent: []
    }
    dir = SystemConfig.ServiceMapTemplateDir + '/' + typename
    # STDERR.puts('looking at  ' + dir  )
    if Dir.exist?(dir)
      Dir.foreach(dir) do |service_dir_entry|
        begin
          if service_dir_entry.start_with?('.') == true
            next
          end
          if service_dir_entry.end_with?('.yaml')
            service = load_service_definition(dir + '/' + service_dir_entry)
            #    STDERR.puts('looking at  ' + dir + '/' + service_dir_entry )
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
    avail_services
  end

  def services_attached_to(objectName, identifier)
    service_manager.services_attached_to(objectName, identifier)
  end

  #
  #  end
  def load_service_definition(filename)
    #open soft link not actual
    yaml_file = File.open(filename)
    begin
      s = SoftwareServiceDefinition.from_yaml(yaml_file)
    ensure
      yaml_file.close
    end
    s
  end

  def load_software_service(params)
    params[:service_container_name] = get_software_service_container_name(params)
    loadManagedService(params[:service_container_name])
  end
end