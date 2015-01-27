require 'tree' 

class ServiceManager 
 
  attr_accessor :last_error 
  
  def initialize
    if File.exists?(SysConfig.ServiceTreeFile)    
      @service_tree = tree_from_yaml()
    else
      @service_tree = Tree::TreeNode.new("Service Manager", "Managed Services and Engines")
      @service_tree << Tree::TreeNode.new("ManagedEngine","Engines")
      @service_tree << Tree::TreeNode.new("ManagedService","Managed Services")
      
      
      
    end
  end
  
  def save_tree
          serialized_object = YAML::dump(@service_tree)          
            f = File.new(SysConfig.ServiceTreeFile,File::CREAT|File::TRUNC|File::RDWR, 0644)
            f.puts(serialized_object)
            f.close
            return true
          rescue Exception=>e
           @last_error=( "load error")
            log_exception(e)
            return false        
  end
  
 
  def attached_services(object)
    
  end
  
  def load_system_services
  
  end
  
  def deregister_available_service service_info_hash
    
  end
  
  def register_available_service service_info_hash
    
  end
  
  def list_attached_services_for(objectName,identifier)

    case objectName
      when "ManagedEngine"
        return attached_managed_engine_services(identifier)
      when "Volume"
        return attached_volume_services(identifier)
      when "Database"
          return attached_database_services(identifier) 
    end
      p :no_object_name_match
      p objectName
      
  end
  
  def attached_managed_engine_services(identifier)
    retval = Hash.new 
    if(@service_tree == nil)
         p :panic_loaded_nil_tree
         return retval
       end
    engine_node = @service_tree["ManagedEngine"][identifier]
      if engine_node == nil
        p :cant_find
        p identifier
        return retval
      end
      engine_node.each do |service|
        st = service.content[:service_type]
          
        if retval.has_key?(st) == false
          retval[st] = Array.new
        end        
        retval[st].push(service.content)                        
      end      
      return retval
  end
  
  def attached_services(service_type,identifier)
    retval = Array.new
    if @service_tree["ManagedService"] ==nil
      p panic_no_managed_service_node
      return retval
    end
      services = @service_tree["ManagedService"][service_type]
        if services == nil
          return retval
        end
        service = services[identifier]
        if service == nil
          return  retval
        end
        service.each do |node|
          retval.push(node.content)
          p node
        end       
  end


  
  #hash has parent_engine
  #hash parent
  def add_service service_hash
     #@service_tree.print_tree
    if(@service_tree == nil)
      p :panic_loaded_nil_tree
      return false
    end
    active_engines_node = @service_tree["ManagedEngine"]
      if(active_engines_node == nil )
        p :nil_active_node
       
        return false
      end
      
    if active_engines_node[service_hash[:parent_engine] ] != nil       
      engine_node = active_engines_node[ service_hash[:parent_engine] ]
    else
      engine_node = Tree::TreeNode.new(service_hash[:parent_engine],"Engine")
      active_engines_node << engine_node
    end
        services_node = engine_node[ service_hash[:service_type] ]
          if services_node == nil
            services_node = Tree::TreeNode.new(service_hash[:service_type],"Service Type")
            engine_node <<  services_node
          end          
      if services_node[service_hash[:name]] != nil
                #FixME need to explain why
                return false
      else
        service_node = Tree::TreeNode.new(service_hash[:name],service_hash)
      services_node << service_node     
      end
  
      
      
provider = service_hash[:service_provider]
  if provider == nil || provider.count ==0
    provider="Engines"
  end 
 services_node = @service_tree["ManagedService"]
 
     
    servicetype_node =  services_node[service_hash[:service_type] ]
      if servicetype_node == nil
        servicetype_node =  Tree::TreeNode.new(service_hash[:service_type],service_hash[:service_type])
        services_node << servicetype_node
      end
      provider_node = servicetype_node[provider]
        if provider_node == nil
          provider_node = Tree::TreeNode.new(provider,provider)
          servicetype_node << provider_node
        end
            
      servicetype_node  = Tree::TreeNode.new(service_hash[:name],service_hash)
      
    save_tree
  end
  
  def remove_service service_hash
    save_tree
  end
  
  def tree_from_yaml()
     begin
       yaml = File.new(SysConfig.ServiceTreeFile,'r')
       p yaml.path
      
       service_tree = YAML::load( yaml )
       p service_tree
       yaml.close
       return service_tree
     rescue Exception=>e
       puts e.message + " with " + yaml.path
     end
  end  
end