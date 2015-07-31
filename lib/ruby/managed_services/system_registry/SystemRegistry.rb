class SystemRegistry < Registry 
  require_relative 'Registry.rb'
  require_relative 'SubRegistry.rb'
  require_relative 'ConfigurationRegistry.rb'
  require_relative 'ManagesEnginesRegistry.rb'
  require_relative 'ServicesRegistry.rb'
   attr_reader :last_error
   
  #@ call initialise Service Registry Tree which loads it from disk or create a new one if none exits
   def initialize() 
     #@service_tree root of the Service Registry Tree
     @system_registry = initialize_tree
     @configuration_registry = ConfigurationRegistry.new(service_configurations_registry)
     @services_registry = ServicesRegistry.new(services_registry)
     @managed_engines_registry = ManagesEnginesRegistry.new( managed_engines_registry)
     
   end
   

  
  
  class OrphanServiceRegistry
    
  end
  
  def add_to_services_registry(service_hash)
    @services_registry.add_to_services_registry(service_hash)
  end   
  def remove_from_services_registry(service_hash)
    @services_registry.remove_from_services_registry(service_hash)
  end
  
  def get_engine_nonpersistant_services(params)
    @managed_engines_registry.get_engine_persistance_services(params,false)
  end
  
  def remove_from_managed_engines_registry(service_hash)
    @managed_engines_registry.add_to_managed_engines_registry(service_hash)    
  end
  def remove_from_managed_engines_registry(service_hash)
     @managed_engines_registry.add_to_managed_engines_registry(service_hash)    
   end
  
  #@return an [Array] of service_hashes regsitered against the Service params[:publisher_namespace] params[:type_path]
    def get_registered_against_service(params)
      
      hashes = Array.new
      service_tree = find_service_consumers(params)
      if service_tree.is_a?(Tree::TreeNode)== true
        hashes = get_all_leafs_service_hashes(service_tree)
      end
      return hashes
    end
  #@ remove an engine matching :engine_name from the service registry, all non persistant serices are removed
  #@ if :remove_all_data is true all data is deleted and all persistant services removed
  #@ if :remove_all_data is not specified then the Persistant services registered with the engine are moved to the orphan services tree
  #@return true on success and false on fail
  def rm_remove_engine(params)

    if params.has_key?(:parent_engine) == false
      params[:parent_engine] = params[:engine_name]
    end
    engines_type_tree = managed_engines_type_tree(params)
    if engines_type_tree.is_a?(Tree::TreeNode) == false
      log_error_mesg("Warning Failed to find engine to remove",params)
      return true
    end
    engine_node =  engines_type_tree[params[:parent_engine]]

    if engine_node.is_a?(Tree::TreeNode) == false
      log_error_mesg("Warning Failed to find engine to remove",params)
      return true
    end
    SystemUtils.debug_output(  :rm_remove_engine_params, params)
    services = get_engine_persistant_services(params)
    services.each do | service |
      if params[:remove_all_data] == true
        if delete_service(service) == false
          log_error_mesg("Failed to remove service ",service)
          return false
        end
      else
        if orphan_service(service) == false
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
  providers =  managed_service_tree.children
  retval=Array.new
  if providers == nil
    log_error_mesg("No providers","")
    return retval
  end
  providers.each do |provider|
    retval.push(provider.name)
  end
  return retval
  end
  
  protected
  
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