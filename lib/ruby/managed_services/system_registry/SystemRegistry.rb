class SystemRegistry < Registry 
  require_relative 'Registry.rb'
  require_relative 'SubRegistry.rb'
  require_relative 'ConfigurationsRegistry.rb'
  require_relative 'ManagedEnginesRegistry.rb'
  require_relative 'ServicesRegistry.rb'
  require_relative 'OrphanServicesRegistry.rb'
 
   
  #@ call initialise Service Registry Tree which loads it from disk or create a new one if none exits
   def initialize() 
     #@service_tree root of the Service Registry Tree
     @system_registry = initialize_tree
     @configuration_registry = ConfigurationsRegistry.new(service_configurations_registry)
     @services_registry = ServicesRegistry.new(services_registry)
     @managed_engines_registry = ManagedEnginesRegistry.new( managed_engines_registry)
     @orphan_server_registry = OrphanServicesRegistry.new( orphaned_services_registry)
     
   end
  def save_as_orphan(params)
      @orphan_server_registry.save_as_orphan(params)
    end  
  def release_orphan(params)
     @orphan_server_registry.release_orphan(params)
   end  
  def reparent_orphan(params)
    @orphan_server_registry.reparent_orphan(params)
  end
  def retrieve_orphan(params)
      @orphan_server_registry.retrieve_orphan(params)
    end
  def get_orphaned_services(params)
    @orphan_server_registry.get_orphaned_services(params)
   end
  def find_orphan_consumers(params)
     @orphan_server_registry.find_orphan_consumers(params)
  end  
    
  def find_service_consumers(service_query_hash)
    @services_registry.find_service_consumers(service_query_hash)
  end
 
  def add_to_services_registry(service_hash)
    @services_registry.add_to_services_registry(service_hash)
  end   
  def remove_from_services_registry(service_hash)
    @services_registry.remove_from_services_registry(service_hash)
  end
  def  find_engine_services_hashes(params)
    @managed_engines_registry.find_engine_services_hashes(params)
  end
 def  find_engine_services_hashes(params)
  @managed_engines_registry.find_engine_services_hashes(params)
end
  def get_engine_nonpersistant_services(params)
    @managed_engines_registry.get_engine_persistance_services(params,false)
  end
  
  def remove_from_managed_engines_registry(service_hash)
    @managed_engines_registry.remove_from_managed_engines_registry(service_hash)    
  end
  def add_to_managed_engines_registry(service_hash)
     @managed_engines_registry.add_to_managed_engines_registry(service_hash)    
   end
  
  #@return an [Array] of service_hashes regsitered against the Service params[:publisher_namespace] params[:type_path]
    def get_registered_against_service(params)
      @services_registry.get_registered_against_service(params)
    
    end
    
  #@ remove an engine matching :engine_name from the service registry, all non persistant serices are removed
  #@ if :remove_all_data is true all data is deleted and all persistant services removed
  #@ if :remove_all_data is not specified then the Persistant services registered with the engine are moved to the orphan services tree
  #@return true on success and false on fail
  def rm_remove_engine(params)

    if params.has_key?(:parent_engine) == false
      params[:parent_engine] = params[:engine_name]
    end
    engines_type_tree = @managed_engines_registry.managed_engines_type_tree(params)
    if managed_engines_registry.is_a?(Tree::TreeNode) == false
      log_error_mesg("Warning Failed to find engine to remove",params)
      return true
    end
    engine_node =  managed_engines_registry[params[:parent_engine]]

    if engine_node.is_a?(Tree::TreeNode) == false
      log_error_mesg("Warning Failed to find engine to remove",params)
      return true
    end
    SystemUtils.debug_output(  :rm_remove_engine_params, params)
    services = @managed_engines_registry.get_engine_persistant_services(params)
    services.each do | service |
      if params[:remove_all_data] == true
        if delete_service(service) == false
          log_error_mesg("Failed to remove service ",service)
          return false
        end
      else
        if @orphan_server_registry.orphan_service(service) == false
          log_error_mesg("Failed to orphan service ",service)
          return false
        end
      end
    end

    if  managed_engines_type_tree(params).remove!(engine_node)
 
      return  save_tree
    else
      log_error_mesg("Failed to remove engine node ",engine_node)
      return false
    end
    log_error_mesg("Failed remove engine",params)
    return true
  end

  #remove service matching the service_hash from both the managed_engine registry and the service registry
  #@return false
  def delete_service service_hash
   
    if remove_from_managed_service(service_hash) == false
      log_error_mesg("failed to remove managed service",service_hash)
      return false
    end
    return remove_service(service_hash)
  end

  
  def list_providers_in_use
    @services_registry.list_providers_in_use
  end
  
 
  
  #@return boolean true if not nil
  def    check_system_registry_tree
    st = system_registry_tree
    if   st.is_a?(Tree::TreeNode) == false
      SystemUtils.log_error_mesg("Nil service tree ?",st)
      return false
    end
    return true
  rescue
    rescue Exception=>e
             log_exception(e)
             return false
  end
  
  def system_registry_tree
    registry=@system_registry
    if @last_tree_mod_time && @last_tree_mod_time != nil 
          current_time = File.mtime(SysConfig.ServiceTreeFile)
          if  @last_tree_mod_time.eql?(current_time) == false
           registry = load_tree
          end
    end
    @system_registry=registry
    return  registry 
    rescue Exception=>e
    log_exception(e)
      return false
  end
  def update_service_configuration(config_hash)
    @configuration_registry.update_service_configuration(config_hash)
  end
  
  def service_configurations_registry
    if check_system_registry_tree == false
          return false
        end
    if ( @system_registry ["Configurations"] == nil )
      @system_registry  << Tree::TreeNode.new("Configurations","Service Configurations")       
    end
    return  @system_registry ["Configurations"]
    rescue Exception=>e
         log_exception(e)
         return nil
  end
  
  #loads the Service tree off disk from [SysConfig.ServiceTreeFile]
    #calls [log_exception] on error and returns nil 
    #@return service_tree [TreeNode]
    def tree_from_yaml()
      begin
        if File.exist?(SysConfig.ServiceTreeFile)
          tree_data = File.read(SysConfig.ServiceTreeFile)
        elsif  File.exist?(SysConfig.ServiceTreeFile + ".bak")
          tree_data = File.read(SysConfig.ServiceTreeFile + ".bak")
        end
        registry =   YAML::load(tree_data)
        return registry
      rescue Exception=>e
        puts e.message + " with " + tree_data.to_s
        log_exception(e)
        return nil
      end
 
    end
    
  
  
  # Load tree from file or create initial service tree
   #@return ServiceTree as a [TreeNode]
   def initialize_tree
     
     if File.exists?(SysConfig.ServiceTreeFile)
       registry = load_tree
     else
       registry = Tree::TreeNode.new("Service Manager", "Managed Services and Engines")
       registry << Tree::TreeNode.new("ManagedEngine","Engines")
       registry << Tree::TreeNode.new("Services","Managed Services")
     end
 
     return registry
   rescue Exception=>e
     puts e.message
     log_exception(e)
 
   end
   
  #@sets the service_tree and loast mod time 
   def load_tree
      registry = tree_from_yaml()
     if File.exist?(SysConfig.ServiceTreeFile)
      @last_tree_mod_time = File.mtime(SysConfig.ServiceTreeFile)
     else
       @last_tree_mod_time =nil
     end
     return registry
     rescue Exception=>e
         @last_error=( "load tree")
         log_exception(e)
         return false
   end
   
 #saves the Service tree to disk at [SysConfig.ServiceTreeFile] and returns tree  
  # calls [log_exception] on error and returns false
    #@return boolean 
    def save_tree
      if File.exists?(SysConfig.ServiceTreeFile)
        statefile_bak = SysConfig.ServiceTreeFile + ".bak"
        FileUtils.copy( SysConfig.ServiceTreeFile,   statefile_bak)
      end
      serialized_object = YAML::dump(@system_registry)
      f = File.new(SysConfig.ServiceTreeFile+".tmp",File::CREAT|File::TRUNC|File::RDWR, 0644)
      f.puts(serialized_object)
      f.close
      #FIXME do a del a rename as killing copu part way through ...
      FileUtils.copy(SysConfig.ServiceTreeFile+".tmp", SysConfig.ServiceTreeFile);
      @last_tree_mod_time = File.mtime(SysConfig.ServiceTreeFile)
      return true
    rescue Exception=>e
      @last_error=( "save error")
      log_exception(e)
      if File.exists?(SysConfig.ServiceTreeFile) == false
        FileUtils.copy(SysConfig.ServiceTreeFile + ".bak", SysConfig.ServiceTreeFile)
      end 
      return false
    end
    
#@return the ManagedServices Tree [TreeNode] Branch
   #  creates if does not exist
  def services_registry()
   
    if check_system_registry_tree == false
      return false
    end
    if @system_registry["Services"].is_a?(Tree::TreeNode) == false
      @system_registry << Tree::TreeNode.new("Services"," Service register")       
     end
   
     return @system_registry["Services"]
       
    rescue Exception=>e
         log_exception(e)
         return false
  end


## returns [TreeNode] under parent_node with the Directory path (in any) in type_path convert to tree branches
# # Creates new attached [TreeNode] with required parent path if none exists
# # return nil on error
# #param parent_node the branch to create the node under
# #param type_path the dir path format as in dns or database/sql/mysql
# def create_type_path_node(parent_node,type_path)
#   if type_path == nil
#     log_error_mesg("create_type_path passed a nil type_path when adding to ",parent_node)
#     return false
#   end
#   if parent_node.is_a?(Tree::TreeNode) == false
#     log_error_mesg("parent node not a tree node ",parent_node)
#           return false
#         end
#   if type_path.include?("/") == false
#     service_node = parent_node[type_path]
#     if service_node == nil
#       service_node = Tree::TreeNode.new(type_path,type_path)
#       parent_node << service_node
#     end
#     return service_node
#   else
#
#     sub_paths= type_path.split("/")
#     prior_node = parent_node
#     count=0
#
#     sub_paths.each do |sub_path|
#       sub_node = prior_node[sub_path]
#       if sub_node == nil
#         sub_node = Tree::TreeNode.new(sub_path,sub_path)
#         prior_node << sub_node
#       end
#       prior_node = sub_node
#       count+=1
#       if count == sub_paths.count
#         return sub_node
#       end
#     end
#   end
#   log_error_mesg("create_type_path failed",type_path)
#   return false
# end
  
def orphaned_services_registry
    
    if check_system_registry_tree == false 
          return false
        end
    orphans = @system_registry["OphanedServices"]
    if orphans.is_a?(Tree::TreeNode) == false
      @system_registry << Tree::TreeNode.new("OphanedServices","Persistant Services left after Engine Deinstall")
      orphans = @system_registry["OphanedServices"]
    end

    return orphans
    rescue Exception=>e
         log_exception(e)
         return nil
  end
 
# @return the ManagedEngine Tree Branch
  # creates if does not exist
  def managed_engines_registry 
    if check_system_registry_tree == false
          return false
        end
    if @system_registry["ManagedEngine"].is_a?(Tree::TreeNode) == false
      @system_registry << Tree::TreeNode.new("ManagedEngine","ManagedEngine Service register")       
    end
    return @system_registry["ManagedEngine"]
    rescue Exception=>e
         log_exception(e)
         return false
  end
  
  
end