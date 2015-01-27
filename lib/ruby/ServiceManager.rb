require 'tree' 

class ServiceManager 
 
  attr_accessor :last_error 
  
  def initialize
    if File.exists?(SysConfig.ServiceTreeFile)    
       tree_from_yaml()
    else
      @service_tree = Tree::TreeNode.new(:services, "Managed Services")
      @service_tree << Tree::TreeNode.new(:active,"Active Engines")
      @service_tree << Tree::TreeNode.new(:deleted,"Deleted Engines")
    end
  end
  
  def save_tree
          serialized_object = YAML::dump(self)          
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
  
  #hash has parent_engine
  #hash parent
  def add_service service_hash
    active_engines_node = @service_tree[:active]
      if(active_engines_node == nil )
        p :nil_active_node
        return false
      end
    if active_engines_node[service_hash[:parent_engine] ] != nil && active_engines_node[ service_hash[:parent_engine] ].present? == true      
      engine_node = active_engines_node[ service_hash[:parent_engine] ]
    else
      engine_node = Tree::TreeNode.new(service_hash[:parent_engine],"Engine")
      active_engines_node << engine_node
    end
        services_node = engine_node[ service_hash[:service_type] ]
          if service_node == nil
            services_node = Tree::TreeNode.new(service_hash[:service_type],"Service Type")
            engine_node <<  service_node
          end          
      if services_node[service_hash[:name]].present? == true
                #FixME need to explain why
                return false
      else
        service_node = Tree::TreeNode.new(service_hash[:name],service_hash)
      services_node << service_node     
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
      
       @service_tree = YAML::load( yaml )
       
       yaml.close
      
     rescue Exception=>e
       puts e.message + " with " + yaml.path
     end
  end  
end