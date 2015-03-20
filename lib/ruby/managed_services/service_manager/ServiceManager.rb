require 'rubytree'
require_relative 'service_manager_tree.rb'
 include 'service_manager_tree.rb'
class ServiceManager

  attr_accessor :last_error
  def initialize
    @service_tree = initialize_tree
                    
#    if File.exists?(SysConfig.ServiceTreeFile)
#      @service_tree = tree_from_yaml()
#    else
#      @service_tree = Tree::TreeNode.new("Service Manager", "Managed Services and Engines")
#      @service_tree << Tree::TreeNode.new("ManagedEngine","Engines")
#      @service_tree << Tree::TreeNode.new("Services","Managed Services")
#    end
#    rescue Exception=>e
#        puts e.message 
#    SystemUtils.log_exception(e)
#        
  end

  def get_software_service_container_name(params)
   server_service =  software_service_definition(params)
   if server_service == nil || server_service == false
     p :no_luck_getint_service_container_for
     p params
     return nil
   end
    return server_service[:service_container]
    
  end
  def list_providers_in_use
     providers =  managed_service_tree.children
     if providers == nil
       return false
      end
     retval=Array.new
     providers.each do |provider|
       retval.push(provider.name)
     end 
     return retval
  end
  
  def managed_service_tree 
    return @service_tree["Services"]
  end
  
  def get_service_provider_tree(publisher)
    managed_service_tree[publisher]
  end
  
  
  
  def find_service_consumers(service_query_hash)
      
      if service_query_hash.has_key?(:publisher_namespace) == false || service_query_hash[:publisher_namespace]  == nil
       p :no_publisher_namespace
        return false
      end
      
    provider_tree = get_service_provider_tree(service_query_hash[:publisher_namespace])
     
      if service_query_hash.has_key?(:type_path) == false  || service_query_hash[:type_path] == nil
        p :find_service_consumers
        p provider_tree
        return provider_tree
      end
            
      service_path_tree = get_type_path_node(provider_tree,service_query_hash[:type_path])
      #provider_tree[service_hash[:type_path]]
     
      if service_path_tree == nil
        return false
      end
            
      if service_query_hash.has_key?(:variables) == false || service_query_hash[:variables]  == nil
        p :find_service_consumers
                p  service_path_tree
        return  service_path_tree
      end
      
      
     if  service_path_tree[service_query_hash[:variables][:name]] == nil
       return false
      end
      
p :find_service_consumers
                p service_path_tree[service_query_hash[:variables][:name]]
      
      return service_path_tree[service_query_hash[:variables][:name]]
      
  end
    
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
  
  def get_type_path_node(parent_node,type_path) 
   if type_path == nil || parent_node == nil
     p :get_type_path_node_passed_a_nil
     return nil
   end
   
   if type_path.include?("/") == false
     return parent_node[type_path]
   
  else
    sub_paths= type_path.split("/")
    sub_node = parent_node
      sub_paths.each do |sub_path|
        sub_node = sub_node[sub_path]
        if sub_node == nil
          return nil
        end 
      end
      return sub_node
  end        
  end
  
#  def attached_services(object)
#
#  end
#
#  def load_system_services
#
#  end
#
#  def deregister_available_service service_info_hash
#
#  end
#
#  def register_available_service service_info_hash
#
#  end

  def list_attached_services_for(objectName,identifier)
    p :services_on_objects_4
    p objectName
    p identifier

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
    rescue Exception=>e
        puts e.message 
    SystemUtils.log_exception(e)
        
  end


  def attached_managed_engine_services(identifier)

    retval = Hash.new

    if identifier == nil
      p :panic_passed_nil_identifier
      return retval
    end
   
    engines_node =  @service_tree["ManagedEngine"]
    if  engines_node ==nil
      p :panic_loaded_managedengine_tree
      return retval
    end

    engine_node =engines_node[identifier]

    if engine_node == nil
      p :cant_find
      p identifier
      return retval
    end
   engine_node.children.each do |service_node|      
      p :service_type
      p service_node.name
      if  service_node.name == nil
        p :no_service_type
        return retval
      end
      if retval.has_key?( service_node.name) == false
        retval[ service_node.name] = Array.new
      end
      retval[ service_node.name].push(get_service_content(service_node))
    end
#    p :retval
#    p retval
    return retval
 
rescue Exception=>e
    puts e.message 
SystemUtils.log_exception(e)
    
  end
  
  def get_service_content(service_node)
    retval = Hash.new
    service_node.children.each do |provider_node|

      retval[provider_node.name] = Array.new
          provider_node.children.each do |service_node|
            retval[provider_node.name].push(service_node.content)
          end       
    end
    return retval
  end
  
  def attached_services(service_type,identifier)
    retval = Array.new
    if @service_tree["ManagedService"] ==nil
      p :panic_no_managed_service_node
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
#      p node
    end
    
rescue Exception=>e
    puts e.message 
SystemUtils.log_exception(e)
    
  end

  #hash has parent_engine
  #hash parent
  def add_service service_hash
    #@service_tree.print_tree
    if(@service_tree == nil)
      p :panic_loaded_nil_tree
      return false
    end
 
    add_to_managed_engines_tree(service_hash)
      add_to_services_tree(service_hash) 
      save_tree
  rescue Exception=>e
      puts e.message 
    SystemUtils.log_exception(e)
      
  end
  
  def add_to_managed_engines_tree(service_hash)
    #write managed engine tree
    active_engines_node = @service_tree["ManagedEngine"]

    if (active_engines_node == nil )
      p :nil_active_node
      return false
    end

    if service_hash[:variables].has_key?(:parent_engine) == false && service_hash[:variables][:parent_engine] != nil
      p :no_parent_engine_key
      return false
    end
    if active_engines_node[service_hash[:variables][:parent_engine] ] != nil
      engine_node = active_engines_node[ service_hash[:variables][:parent_engine] ]
    else
      engine_node = Tree::TreeNode.new(service_hash[:variables][:parent_engine],service_hash[:variables][:parent_engine] + " Engine Service Tree")
      active_engines_node << engine_node
    end

    service_type_node = create_type_path_node(engine_node,service_hash[:type_path])
      
    
    service_label = get_service_label(service_hash)
    
if service_type_node == nil 
  p service_hash
  p :error_service_type_node
  return false
end   
if service_label == nil 
  p service_hash
  p :error_service_hash_has_nil_name
  return false
end

    service_node = service_type_node[service_label]
    
    if  service_node == nil
      service_node = Tree::TreeNode.new(service_label,service_hash)
      service_type_node << service_node
    else
      p :Node_existed
      p service_label
    end
    
 
end
    
def get_service_label(params)
  if params.has_key?(:name) && params[:name] != nil
       service_label = params[:name]
     elsif  params.has_key?(:variables) && params[:variables].has_key?(:name)
       service_label = params[:variables][:name]
     else
       return nil
     end
end

 #write services tree
   def add_to_services_tree(service_hash)
   
     services_node = @service_tree["Services"]
   

       provider_node = services_node[service_hash[:publisher_namespace] ]
        if provider_node == nil
          provider_node = Tree::TreeNode.new(service_hash[:publisher_namespace] ," Provider:" + service_hash[:publisher_namespace] + ":" + service_hash[:type_path]  )
          services_node << provider_node
        end
        
        service_type_node = create_type_path_node(provider_node,service_hash[:type_path])
   
          service_node = service_type_node[service_hash[:variables][:parent_engine]]
            if service_node == nil
              service_node = Tree::TreeNode.new(service_hash[:variables][:parent_engine],service_hash)
              service_type_node << service_node
            end
    #FIXME need to handle updating service 
            
rescue Exception=>e
    puts e.message 
SystemUtils.log_exception(e)
    
  end
  
  def get_managed_engine_tree
      return @service_tree["ManagedEngine"]
  end

  def get_orphaned_services_tree
    orphans = @service_tree["OphanedServices"]
              if orphans == nil
                @service_tree << Tree::TreeNode.new("OphanedServices","Persistant Services left after Engine Deinstall")
                orphans = @service_tree["OphanedServices"]
              end
              
              return orphans
  end
  
  def find_engine_services(params)
    engine_node = @service_tree["ManagedEngine"][params[:engine_name]]
      
      if params.has_key?(:type_path) && params[:type_path] != nil
        services = get_type_path_node(engine_node,params[:type_path]) #engine_node[params[:type_path]]                   
              if services != nil  && params.has_key?(:name) && params[:name] != nil
                 service = services[params[:name]]
                return service
              else
            return services
          end      
      else
        return engine_node
    end
  end

  def get_engine_persistant_services(params) #params is :engine_name
    services = find_engine_services(params)
    
    leafs = Array.new
    
     services.children.each do |service|
       matches = get_matched_leafs(service,:persistant,true)
       p matches
       leafs =  leafs.concat(matches)
    end
    
    return leafs
    
  end
  
  def get_matched_leafs(branch,label,value)
    ret_val = Array.new
    branch.children.each do |sub_branch|
           if sub_branch.children.count == 0
#             p sub_branch.content
#             p sub_branch.content[label]
              if  sub_branch.content[label] == value 
#                p :found
#                p  sub_branch.content
                  ret_val.push(sub_branch.content)  
              end
           else
          ret_val += get_matched_leafs(sub_branch,label,value) 
       end
    end
       return ret_val
  end
  
  def rm_remove_engine(params)
    managed_engine_tree =  get_managed_engine_tree

       engine_node = managed_engine_tree[params[:engine_name]]
        p :rm_remove_engine
        p params
        
        if engine_node == nil
          return false
        end

          if params[:remove_all_application_data] == true
            p :removed_all
           services = get_engine_persistant_services(params)
           services.each do | service |
             p :removing_Service
             remove_service(service)
           end
            # managed_engine_tree.print_tree
            managed_engine_tree.remove!(engine_node)
            save_tree
            return true
          end
                  
         # keeping persistant   
         #remove non persistant 
                
         managed_engine_tree.remove!(engine_node)
         uninstalled = get_orphaned_services_tree
    
           uninstalled << engine_node                     
           
           save_tree
           return true
  end
  
  def remove_service service_hash
   
      parent_engine_node = @service_tree["ManagedEngine"][service_hash[:variables][:parent_engine]]
        if parent_engine_node == nil
          @last_error ="No services record found for "+ service_hash[:variables][:parent_engine] 
          p   @last_error
          return false
        end 
        
service_type_node =  get_type_path_node(parent_engine_node,service_hash[:type_path]) 
        
    #  parent_engine_node[]
        if service_type_node == nil
          @last_error ="No service record found for " + service_hash[:variables][:parent_engine] + ":" +  service_hash[:service_type]
          p   @last_error
          return false
        end
        
#       service_provider_node =  service_type_node[service_hash[:publisher_namespace]]
#       if service_provider_node == nil
#         p service_type_node.children 
#          @last_error ="No service record found for " + service_hash[:variables][:parent_engine] + " type_path:" +  service_hash[:type_path] + " Provider " + service_hash[:publisher_namespace]
#            p   @last_error
#          return false
#        end
        service_name = get_service_label(service_hash)
        if service_name  == nil
          p service_hash
          p :notfound
        end 
        service_node = service_type_node[service_name]
        #deal with new way variables are pass 
      

#          p :really_removing
#          p service_node
#         p :from
         # p service_provider_node
          #FIXME a method should do this in a loop
          
          if service_node != nil          
              service_type_node.remove!(service_node)              
                if service_type_node.children.count ==0
                  parent_engine_node.remove!(service_type_node)
                    if parent_engine_node.children.count == 0
                      @service_tree["ManagedEngine"].remove!(parent_engine_node)
                    end
                end
            end

      sucess =  true
            
      services_node = @service_tree["Services"]
      if services_node !=nil
        provider_node = services_node[service_hash[:publisher_namespace] ]
        if provider_node != nil
          servicetype_node =  get_type_path_node(provider_node,service_hash[:type_path] )
          if servicetype_node != nil
            service_node = servicetype_node[service_hash[:variables][:parent_engine]]
            if service_node != nil
              servicetype_node.remove!(service_node)
              if servicetype_node.children.count == 0
                provider_node.remove!(service_node)
                if provider_node.children.count == 0
                  service_node.remove!(provider_node)
                end
              end
            else
              sucess =  false
            end  
            else
                          sucess =  false                       
          end
          else
              sucess =  false
        end
        else
              sucess =  false

    p "failed to load service tree!"
           
          end         
          
          if sucess == true
            save_tree
            return true
          else
            p :FAILED_TO_REMOVE_SERVICE
            p service_hash
          end
          
@last_error ="No service record found for " + service_hash[:variables][:parent_engine].to_s
@last_error += " service_type:" +  service_hash[:type_path].to_s 
@last_error  += " Provider " + service_hash[:publisher_namespace].to_s 
@last_error += " Name " + service_hash[:variables][:name].to_s
        return false 

rescue Exception=>e
  if service_hash != nil
    p service_hash
  end
SystemUtils.log_exception(e)
  return false    
  end

def software_service_definition(params)
  
 return  SoftwareServiceDefinition.find(params[:type_path],params[:publisher_namespace] )
#  require 'json'
#  
#  if params[:publisher_namespace]   == nil ||  params[:type_path] == nil
#    p :nil_in_params
#    p params
#    return nil
#  end
#  
#  service_filename = SysConfig.ServiceTemplateDir + "/" + params[:publisher_namespace] + "/" + params[:type_path]+ ".yaml"
#  if File.exists?(service_filename)
#    yaml = File.read(service_filename)
#    software_service_def  = SoftwareServiceDefinition.from_yaml(yaml)
#    return software_service_def.to_h
#  else
#    p :no_file_named
#    p  service_filename 
#    return nil
#  end

    
rescue Exception=>e
  p :error
  p params
  
  SystemUtils.log_exception(e)
  return nil
end  


  
#  
#  def tree_from_yaml()
#    begin
#      tree_data = File.read(SysConfig.ServiceTreeFile)
#      service_tree =   YAML::load(tree_data)
#      return service_tree
#    rescue Exception=>e
#      puts e.message + " with " + tree_data.to_s
#      SystemUtils.log_exception(e)
#    end
#  end
#
#  protected
#  
#  def save_tree
#  #  serialized_object = Marshal.dump(@service_tree)
#    serialized_object = YAML::dump(@service_tree)
#    f = File.new(SysConfig.ServiceTreeFile,File::CREAT|File::TRUNC|File::RDWR, 0644)
#    f.puts(serialized_object)
#    f.close
#    return true
#  rescue Exception=>e
#    @last_error=( "load error")
#    SystemUtils.log_exception(e)
#    return false
#  end

  
end