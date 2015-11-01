require '/opt/engines/lib/ruby/api/system/errors_api.rb'
class DNSApi < ErrorsApi
  
  def initialize(service_manager)
    @service_manager = service_manager
end
  def add_domain(params)
     return false unless DNSHosting.add_domain(params)
     return true unless params[:self_hosted]
     service_hash = {}
     service_hash[:parent_engine] = 'system'
     service_hash[:variables] = {}
     service_hash[:variables][:domain_name] = params[:domain_name]
     service_hash[:service_handle] = params[:domain_name] + '_dns'
     service_hash[:container_type] = 'system'
     service_hash[:publisher_namespace] = 'EnginesSystem'
     service_hash[:type_path] = 'dns'
     service_hash[:variables][:ip] = get_ip_for_hosted_dns(params[:internal_only])
     return true if @service_manager.add_service(service_hash)
     @last_error = @service_manager.last_error
     return false
   rescue StandardError => e
     log_error_mesg('Add self hosted domain exception', params.to_s)
     log_exception(e)
   end
   
  def update_domain(params)
     old_domain_name = params[:original_domain_name]
     return false unless DNSHosting.update_domain(old_domain_name, params)
     return true unless params[:self_hosted]
     service_hash =  {}
     service_hash[:parent_engine] = 'system'
     service_hash[:variables] = {}
       if params.key?(:original_domain_name)       
        service_hash[:variables][:domain_name] = old_domain_name
        service_hash[:service_handle] = old_domain_name + '_dns'
       else
         service_hash[:variables][:domain_name] = params[:domain_name]
         service_hash[:service_handle] = params[:domain_name] + '_dns'      
     end
     service_hash[:container_type] = 'system'
     service_hash[:publisher_namespace] = 'EnginesSystem'
     service_hash[:type_path] = 'dns'
 
     @service_manager.deregister_non_persistant_service(service_hash)
     service_hash[:variables][:domain_name] = params[:domain_name]
     service_hash[:service_handle] = params[:domain_name] + '_dns'
     service_hash[:variables][:ip] = get_ip_for_hosted_dns(params[:internal_only])
     return @service_manager.register_non_persistant_service(service_hash) if @service_manager.add_service(service_hash)
     return false
   rescue StandardError => e
     SystemUtils.log_exception(e)
   end
   
  def remove_domain(params)
    return false if DNSHosting.rm_domain(params) == false
    return true if params[:self_hosted] == false
    service_hash = {}
    service_hash[:parent_engine] = 'system'
    service_hash[:variables] = {}
    service_hash[:variables][:domain_name] = params[:domain_name]
    service_hash[:service_handle] = params[:domain_name] + '_dns'
    service_hash[:container_type] = 'system'
    service_hash[:publisher_namespace] = 'EnginesSystem'
    service_hash[:type_path] = 'dns'
    if @service_manager.delete_service(service_hash) == true
      @service_manager.deregister_non_persistant_service(service_hash)
      @service_manager.delete_service_from_engine_registry(service_hash)
      return true
    end
    return false
  rescue StandardError => e
    log_exception(e)
  end
  
  def self.list_domains
    return DNSHosting.list_domains
  rescue StandardError => e
    SystemUtils.log_exception(e)
  end
  
def get_ip_for_hosted_dns(internal)
   return DNSHosting.get_local_ip if internal
   open('http://jsonip.com/') { |s| JSON::parse(s.string)['ip'] }
 end
 
end