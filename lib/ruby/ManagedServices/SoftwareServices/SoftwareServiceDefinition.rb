class SoftwareServiceDefinition
  attr_reader :accepts,
              :author,
              :title,
              :description,
              :service_name,
              :consumer_params,
              :setup_params,
              :dedicated,
              :service_type, 
              :service_provider,
              :service_container, 
              :persistant

  
  def self.from_yaml( yaml )
     begin
      # p yaml.path
       serviceDefinition = YAML::load( yaml )
   
       return serviceDefinition
     rescue Exception=>e
       puts e.message + " with " + yaml
     end
  end
  
  def SoftwareServiceDefinition.find(service_type,provider)
    dir = SysConfig.ServiceTemplateDir + "/" 
          p :dir
          p dir 
          p :looking_for
          p provider
          p service_type
          
          #FIXME and support more than one dir
          if service_type.include?("/")
            service_type =  service_type.sub(/.*\//,"")
            dir += service_type.sub(/\/.*/,"")
            p :sub_service
            p dir 
            p service_type
            
          end
    
          if Dir.exist?(dir)
            return search_dir(dir,service_type)
          end
  end
  
  def search_dir(dir,service_type)
    return SoftwareServiceDefinition.search_dir(dir,service_type)
  end
  
  def SoftwareServiceDefinition.search_dir(dir,service_type)
    root = dir
    if Dir.exists?(dir)
      Dir.foreach(dir) do |service_dir_entry|
        if Dir.exist?(service_dir_entry) == true && service_dir_entry.start_with?(".") ==false
          search_dir(root + "/" + service_dir_entry,service_type)
        else
          if File.exist?(root + "/" + service_dir_entry + "/" + service_type + ".yaml" )
            return find(dir,service_type)
          end
        end
      end
    end
  end

  def to_h
    require 'json'
    return JSON.parse(self.to_json, {:symbolize_names => true})
  end
end