require 'rubytree'

require_relative 'service_manager_tree.rb'
include ServiceManagerTree
require_relative 'orphaned_services.rb'
include OrphanedServices
require_relative 'managed_engines_registry.rb'
include ManagedEnginesRegistry
require_relative 'services_registry.rb'
include ServicesRegistry

class ServiceManager
  
  #@service_tree root of the Service Registry Tree
  attr_accessor   :service_tree
  :last_error
  #@ call initialise Service Registry Tree which loads it from disk or create a new one if none exits
  def initialize
    #@service_tree root of the Service Registry Tree
    @service_tree = initialize_tree
  end

  #Find the assigned service container_name from teh service definition file
  def get_software_service_container_name(params)

    server_service =  software_service_definition(params)

    if server_service == nil || server_service == false
      log_error_mesg("Failed to load service definitions",params)
      return nil
    end
    return server_service[:service_container]

  end

  #list the Provider namespaces as an Array of Strings
  #@return [Array]
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

  # returns [TreeNode] under parent_node with the Directory path (in any) in type_path convert to tree branches
  # Creates new attached [TreeNode] with required parent path if none exists
  # return nil on error
  #param parent_node the branch to create the node under
  #param type_path the dir path format as in dns or database/sql/mysql
  def create_type_path_node(parent_node,type_path)
    if type_path == nil
      log_error_mesg("create_type_path passed a nil type_path when adding to ",parent_node)
      return nil
    end

    if type_path.include?("/") == false
      service_node = parent_node[type_path]
      if service_node == nil
        service_node = Tree::TreeNode.new(type_path,type_path)
        parent_node << service_node
      end
      return service_node
    else

      sub_paths= type_path.split("/")
      prior_node = parent_node
      count=0

      sub_paths.each do |sub_path|
        sub_node = prior_node[sub_path]
        if sub_node == nil
          sub_node = Tree::TreeNode.new(sub_path,sub_path)
          prior_node << sub_node
        end
        prior_node = sub_node
        count+=1
        if count == sub_paths.count
          return sub_node
        end
      end
    end
log_error_mesg("create_type_path failed",type_path)
    return nil
  end

  #remove service matching the service_hash from both the managed_engine registry and the service registry
  #@return false
  def remove_service service_hash

    if remove_from_engine_registery(service_hash) == false
      log_error_mesg("failed to remove from engine registry",service_hash)
      return false
    end

    if remove_from_services_registry(service_hash) == false
      log_error_mesg("failed to remove from service registry",service_hash)
      return false
    end
    p :remove_service 
    p service_hash
    return save_tree

  rescue Exception=>e
    if service_hash != nil
      p service_hash
    end
    log_exception(e)
    return false
  end

  #@return [Array] of service hash for ObjectName matching the name  identifier
  #@objectName [String]
  #@identifier [String]
  
  def list_attached_services_for(objectName,identifier)
    p :services_on_objects_4
    SystemUtils.debug_output("services_on_objects_",objectName)
    SystemUtils.debug_output("services_on_objects_",identifier)

    params = Hash.new

    case objectName
    when "ManagedEngine"
      params[:engine_name] = identifier
      p :get_engine_service_hashes
      hashes = find_engine_services_hashes(params)
      SystemUtils.debug_output("hashes",hashes)

      return find_engine_services_hashes(params)
      #    attached_managed_engine_services(identifier)
    when "Volume"
      p :looking_for_volume
      p identifier
      return attached_volume_services(identifier)
    when "Database"
      p :looking_for_database
      p identifier
      return attached_database_services(identifier)
    end
    p :no_object_name_match
    p objectName

    return nil

  rescue Exception=>e
    puts e.message
    log_exception(e)

    return nil

  end

  
#  def get_service_content(service_node)
#    retval = Hash.new
#    service_node.children.each do |provider_node|
#      if retval[provider_node.name] == nil
#        retval[provider_node.name] = Array.new
#      end
#      provider_node.children.each do |service_node|
#        retval[provider_node.name].push(service_node.content)
#        retval.push(service_node.content)
#      end
#    end
#    return retval
#  end

  #load softwwareservicedefinition for serivce in service_hash and
  #@return boolean indicating the persistance 
  #@return nil if no software definition found
  def software_service_persistance(service_hash)
    service_definition = software_service_definition(service_hash)
    if service_definition != nil && service_definition != nil
      return service_definition[:persistant]
    end
    return nil
  end
  
  #@ Add Service to the Service Registry Tree
  #@ Separatly to the ManagesEngine/Service Tree and the Services tree
  #@ return true if successful or false if failed
  def add_service service_hash

    if service_hash.has_key?(:persistant) == false
       persist = software_service_persistance(service_hash)
       if persist == nil 
         log_error_mesg("Failed to get persistance status for ",service_hash)
         return false
       end
      service_hash[:persistant] = persist
    end 
    
    if add_to_managed_engines_tree(service_hash) == false
      log_error_mesg("Failed to add service to managed engine registry",service_hash)
      return false
    end

    if add_to_services_tree(service_hash) == false
    log_error_mesg("Failed to add service to managed service registry",service_hash)
    return false
  end

    return save_tree

  rescue Exception=>e
    puts e.message
    log_exception(e)
    return false
  end

  #@return the service_handle from the service_hash
  # for backward compat (to be changed)
  def get_service_handle(params)

    if  params.has_key?(:service_handle) && params[:service_handle] != nil
     
    else
      log_error_mesg("no :service_handle",params)
      
      return nil
    end
  end

  #@param tree_node [TreeNode]
  #@type_path [String]
  #@return [Array] of [TreeNode] s matching type_path under the [TreeNode] tree_node
  # 
  def get_all_engines_type_path_node(tree_node,type_path)
    retval = Array.new

    tree_node.children.each do | engine_node |
      retval.push(get_type_path_node(engine_node,type_path))
    end

    if retval.count == 1
      return retval[0]
    elsif retval.count == 0
      log_error_mesg("no match " + type_path.to_s + " under:" ,service)
      return nil
    else
      return retval
    end
  end

  #@ remove an engine matching :engine_name from the service registry, all non persistant serices are removed
  #@ if :remove_all_application_data is true all data is deleted and all persistant services removed
  #@ if :remove_all_application_data is not specified then the Persistant services registered with the engine are moved to the orphan services tree
  #@return true on success and false on fail
  def rm_remove_engine(params)
    
  if params.has_key?(:parent_engine) == false
    params[:parent_engine] = params[:engine_name] 
  end
    engine_node = managed_engine_tree[params[:parent_engine]]

    if engine_node == nil
      log_error_mesg("Failed to find engine to remove",params)
      return false
    end

    services = get_engine_persistant_services(params)
    services.each do | service |
      if params[:remove_all_application_data] == true
        if remove_service(service) == false
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

    if managed_engine_tree.remove!(engine_node)
      return  save_tree
    else
      log_error_mesg("Failed to remove engine node ",engine_node)
      return false
    end
log_error_mesg("Failed remove engine",params)
    return false
  end

  #@returns boolean indicating sucess
  #Saves service_hash in orphan registry before removing from service registry
  def orphan_service(service_hash)
    if save_as_orphan(service_hash)
      return  remove_service(service_hash)
   end
      log_error_mesg("Failed to save orphan",service_hash)
    
    return false

  end

  #@return [Hash] of [SoftwareServiceDefinition] that Matches @params with keys :type_path :publisher_namespace
  def software_service_definition(params)

    return  SoftwareServiceDefinition.find(params[:type_path],params[:publisher_namespace] )

  rescue Exception=>e
    p :error
    p params

    log_exception(e)
    return nil
  end

  #Sets @last_error to msg + object.to_s (truncated to 256 chars)
  #Calls SystemUtils.log_error_msg(msg,object) to log the error
  #@return none
  def log_error_mesg(msg,object)
    obj_str = object.to_s.slice(0,256)
    
    @last_error = msg +":" + obj_str
    SystemUtils.log_error_mesg(msg,object)

  end

  def log_exception(e)
    @last_error = e.to_s.slice(0,256)
    SystemUtils.log_exception(e)
  end
end
