require '/opt/engines/lib/ruby/api/system/errors_api.rb'
class Container < ErrorsApi
  
#  def initialize(mem, name, host, domain, image, e_ports, vols, environs) # for test only
#    @memory = mem
#    @container_name = name
#    @hostname = host
#    @domain_name = domain
#    @image = image
#    @eports = e_ports
#    @volumes = vols
#    @environments = environs
#    @container_id = -1
#    @docker_info = nil
#  end
  
  def self.from_yaml(yaml, container_api)
    managedContainer = YAML.load(yaml)
    return SystemUtils.log_error_mesg(" Failed to Load yaml ", yaml) if managedContainer.nil?
    managedContainer.container_api = container_api
    managedContainer.expire_engine_info
    managedContainer.set_running_user
    managedContainer.lock_values
    return managedContainer
  rescue Exception => e
    SystemUtils.log_exception(e)
  end
  
  attr_reader :docker_info,\
               :container_id,\
               :memory,\
               :container_name,\
               :hostname,\
               :domain_name,\
               :image,\
               :eports,\
               :volumes,\
               :environments
  attr_accessor :last_error,\
                :container_api,
                :last_result
  
  def update_memory(new_memory)
    @memory = new_memory
  end
  
  def read_state
    info = docker_info
    state = nil
            if info[0]['State']
              if info[0]['State']['Running']
                state = 'running'
                if info[0]['State']['Paused']
                  state= 'paused'
                end
              elsif info[0]['State']['Running'] == false
                state = 'stopped'
              else
                state = 'nocontainer'
              end
            end
           return state
  end
         
  def collect_docker_info
      return false unless has_api?  
      result = @container_api.inspect_container(self) if @docker_info.is_a?(FalseClass)
      return false if result == false
      @docker_info = @last_result
      Thread.new { sleep 3 ; expire_engine_info }
      return result
    end
   
  def docker_info
     collect_docker_info if @docker_info.is_a?(FalseClass)     
     return JSON.parse(@docker_info) 
   rescue
     return false
   end
 
  
end
