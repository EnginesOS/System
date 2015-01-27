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
              :persistant

  
  def self.from_yaml( yaml )
     begin
       p yaml.path
       serviceDefinition = YAML::load( yaml )
   
       return serviceDefinition
     rescue Exception=>e
       puts e.message + " with " + yaml.path
     end
  end
  
  def find(service_type,provider)
    dir = SysConfig.ServiceTemplateDir + "/" 
          p :dir
          p dir 
          if Dir.exists?(dir)
            Dir.foreach(dir) do |service_dir_entry|
                if service_dir_entry.directory? == true
                  if service_type.exist?()
                    p service_type
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