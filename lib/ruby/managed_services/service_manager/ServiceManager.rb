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
      return nil
    end
    return server_service[:service_container]

  end

  #list the Provider namespaces as an Array of Strings
  def list_providers_in_use
    providers =  managed_service_tree.children
    retval=Array.new
    if providers == nil
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
    return nil
  end

#remove service matching the service_hash from both the managed_engine registry and the service registry
def remove_service service_hash

  if remove_from_engine_registery(service_hash) == false
    SystemUtils.log_error_msg("failed to remove from engine regsitry",service_hash)
    return false
  end

  if remove_from_engine_registery(service_hash) == false
     SystemUtils.log_error_msg("failed to remove from service regsitry",service_hash)
     return false
   end
 return true


rescue Exception=>e
  if service_hash != nil
    p service_hash
  end
  SystemUtils.log_exception(e)
  return false
end
 

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
    SystemUtils.log_exception(e)

    return nil

  end

  def get_service_content(service_node)
    retval = Hash.new
    service_node.children.each do |provider_node|
      if retval[provider_node.name] == nil
        retval[provider_node.name] = Array.new
      end
      provider_node.children.each do |service_node|
        retval[provider_node.name].push(service_node.content)
        retval.push(service_node.content)
      end
    end
    return retval
  end

 

  #@ Add Service to the Service Registry Tree
  #@ Separatly to the ManagesEngine/Service Tree and the Services tree
  #@ return true if successful or false if failed
  def add_service service_hash

    add_to_managed_engines_tree(service_hash)

    add_to_services_tree(service_hash)

    return save_tree

  rescue Exception=>e
    puts e.message
    SystemUtils.log_exception(e)
    return false
  end

 
  #return the service_handle from the service_hash
  # for backward compat (to be changed)
  def get_service_handle(params)

    if  params.has_key?(:service_handle) && params[:service_handle] != nil
      return  params[:service_handle]
#       elsif params.has_key?(:name) && params[:name] != nil
#      service_label = params[:name]
#    elsif  params.has_key?(:variables) && params[:variables].has_key?(:name)
#      service_label = params[:variables][:name]
    else
      return nil
    end
  end

  
  
  def get_all_engines_type_path_node(tree_node,type_path)
    retval = Array.new

    tree_node.children.each do | engine_node |
      retval.push(get_type_path_node(engine_node,type_path))
    end

    if retval.count == 1
      return retval[0]
    elsif retval.count == 0
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

    engine_node = managed_engine_tree[params[:engine_name]]

    if engine_node == nil
      return false
    end

    if params[:remove_all_application_data] == true
      services = get_engine_persistant_services(params)
      services.each do | service |
        p :removing_Service
        remove_service(service)
      end
      managed_engine_tree.remove!(engine_node)
      save_tree
      return true
    end
end

#@return [SoftwareServiceDefinition] that Matches @params with keys :type_path :publisher_namespace
  def software_service_definition(params)

    return  SoftwareServiceDefinition.find(params[:type_path],params[:publisher_namespace] )

  rescue Exception=>e
    p :error
    p params

    SystemUtils.log_exception(e)
    return nil
  end

end
