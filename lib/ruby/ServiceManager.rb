require 'tree' 

class ServiceManager 
 
  
  def initialize
    if File.exists?(SysConfig.ServiceTreeFile)    
       tree_from_yaml()
    else
      service_tree = Tree::TreeNode.new("Services", "Managed Services")
      service_tree << Tree::TreeNode("Active","Active Engines")
      service_tree << Tree::TreeNode("Deleted","Active Engines")
    end
  end
  
  def save_tree
          serialized_object = YAML::dump(self)          
            f = File.new(SysConfig.ServiceTreeFile,File::CREAT|File::TRUNC|File::RDWR, 0644)
            f.puts(serialized_object)
            f.close
            return true
          rescue Exception=>e
            container.last_error=( "load error")
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
  
  #hash has parent_engine
  #hash parent
  def add_service service_hash
   
    if service_tree[ service_hash[:parent_engine] ].present? == true
      engine_node = service_tree[ service_hash[:parent_engine] ]
        services_node = engine_node[ service_hash[:service_type] ]
          if service_node == nil
            services_node = Tree::TreeNode(service_hash[:service_type],"Service Type")
            engine_node <<  service_node
          end
          
      if services_node[service_hash[:name]].present? == true
                #FixME need to explain why
                return false
      else
        service_node = Tree::TreeNode(service_hash[:name],service_hash)
      services_node << service_node     
      end
  end 
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
       
      
     rescue Exception=>e
       puts e.message + " with " + yaml.path
     end
  end  
end