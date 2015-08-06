require '/opt/engines/lib/ruby/managed_services/system_registry/NetworkSystemRegistry.rb'
class SystemRegistry
  attr_accessor :network_registry
  def initialize(core_api)
    
    registry_ip = core_api.get_registry_ip
    
    if registry_ip.is_a?(String)
      @network_registry = NetworkSystemRegistry.new(registry_ip,SysConfig.RegistryPort)
    else
      SystemUtils.log_error_mesg("Failed to Create Network Registry", + last_log)
    end
    
  end
  def  find_engine_services(params)    
     result = send_request("find_engine_services",params)
   end
 
   def  find_engine_services_hashes(params)
     send_request("find_engine_services_hashes",params)
   end
 
   def get_engine_nonpersistant_services(params)
     send_request("get_engine_nonpersistant_services",params)
   end
 
   def get_engine_persistant_services(params)
     send_request("get_engine_persistant_services",params)
   end
 
   def remove_from_managed_engines_registry(service_hash)
     send_request("remove_from_managed_engines_registry",service_hash)
   end
 
   def add_to_managed_engines_registry(service_hash)
     send_request("add_to_managed_engines_registry",service_hash)
   end
 
   #
   def save_as_orphan(params)
     send_request("save_as_orphan",params)
   end
 
   def release_orphan(params)
     send_request("release_orphan",params)
   end
 
   #
   def reparent_orphan(params)
     send_request("reparent_orphan",params)
   end
 
   #
   def retrieve_orphan(params)
     send_request("retrieve_orphan",params)
   end
 
   #
   def get_orphaned_services(params)
     send_request("get_orphaned_services",params)
   end
 
   #
   def find_orphan_consumers(params)
     send_request("find_orphan_consumers",params)
   end
 
   #
   def orphan_service(service_hash)
     send_request("orphan_service",service_hash)
   end
 
   #
   #
   def  find_service_consumers(service_query_hash)
     send_request("find_service_consumers",service_query_hash)
   end
 
   #
   def  update_attached_service(service_hash)
     send_request("update_attached_service",service_hash)
   end
 
   #
   def  add_to_services_registry(service_hash)
     send_request("add_to_services_registry",service_hash)
   end
 
   #
   def  remove_from_services_registry(service_hash)
     send_request("remove_from_services_registry",service_hash)
   end
 
   #
   def  service_is_registered?(service_hash)
     send_request("service_is_registered?",service_hash)
   end
 
   #
   def  get_registered_against_service(params)
     send_request("get_registered_against_service",params)
   end
 
   #
   #
   def  get_service_configurations_hashes(service_hash)
     send_request("get_service_configurations_hashes",service_hash)
   end
 
   #
   def  update_service_configuration(config_hash)
     send_request("update_service_configuration",config_hash)
   end
 
   #
   def  list_providers_in_use
     send_request("list_providers_in_use",nil)
   end
 
   #
   #
   def  system_registry_tree
     send_request("system_registry_tree",nil)
   end
 
   #
   def  service_configurations_registry
     send_request("service_configurations_registry",nil)
   end
 
   #
   def  orphaned_services_registry
     send_request("orphaned_services_registry",params)
   end
 
   #
   def  services_registry
     send_request("services_registry",params)
   end
 
   #
   def  managed_engines_registry
     send_request("managed_engines_registry",params)
   end
   
   def last_log
     return @network_registry.last_log
   end
   private 
   def send_request(command,params)
     @network_registry.send_request(command,params)   
   end
end