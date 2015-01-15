class SoftwareServiceDefinition
  attr_reader :accepts,
              :author,
              :title,
              :description,
              :service_name,
              :consumer_params,
              :setup_params,
              :dedicated
  
  def self.from_yaml( yaml )
     begin
       p yaml.path
       serviceDefinition = YAML::load( yaml )
   
       return serviceDefinition
     rescue Exception=>e
       puts e.message + " with " + yaml.path
     end
  end
  
  def to_h
    require 'json'
    return JSON.parse(self.to_json, {:symbolize_names => true})
  end
end