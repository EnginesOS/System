require 'tree'

class ServiceManager

  attr_accessor :last_error
  def initialize
    if File.exists?(SysConfig.ServiceTreeFile)
      @service_tree = tree_from_yaml()
    else
      @service_tree = Tree::TreeNode.new("Service Manager", "Managed Services and Engines")
      @service_tree << Tree::TreeNode.new("ManagedEngine","Engines")
      @service_tree << Tree::TreeNode.new("Services","Managed Services")
    end
    rescue Exception=>e
        puts e.message 
        log_exception(e)
        
  end

  def get_software_service_container_name(params)
   server_service =  software_service_definition(params)
   if server_service == nil
     return nil
   end
    return server_service[:service_container]
    
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
        log_exception(e)
        
  end

  def attached_volume_services (identifier)
    retval=Hash.new
    return retval
  end
  
  def attached_database_services (identifier)
    retval=Hash.new
    return retval
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
    p :retval
    p retval
    return retval
 
rescue Exception=>e
    puts e.message 
    log_exception(e)
    
  end
  
  def get_service_content(service_node)
    retval = Hash.new
    service_node.children.each do |provider_node|
      p :provider_node_name
      p provider_node.name
      retval[provider_node.name] = Array.new
          provider_node.children.each do |service_node|
            p :service_node_name
            p service_node.name
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
      p node
    end
    
rescue Exception=>e
    puts e.message 
    log_exception(e)
    
  end

  #hash has parent_engine
  #hash parent
  def add_service service_hash
    #@service_tree.print_tree
    if(@service_tree == nil)
      p :panic_loaded_nil_tree
      return false
    end

    #write managed engine tree
    active_engines_node = @service_tree["ManagedEngine"]

    if (active_engines_node == nil )
      p :nil_active_node
      return false
    end

    if service_hash.has_key(:parent_engine) == false
      p :no_parent_engine_key
      return false
    end
    if active_engines_node[service_hash[:parent_engine] ] != nil
      engine_node = active_engines_node[ service_hash[:parent_engine] ]
    else
      engine_node = Tree::TreeNode.new(service_hash[:parent_engine],service_hash[:parent_engine] + " Engine Service Tree")
      active_engines_node << engine_node
    end
    
    service_type_node = engine_node[service_hash[:service_type]]
      
     if service_type_node == nil
      service_type_node = Tree::TreeNode.new(service_hash[:service_type], service_hash[:service_type] + " Service")
       engine_node << service_type_node       
    end
    
    provider = service_hash[:service_provider]
     if provider == nil || provider.length ==0
       provider="Engines"
     end
     
    service_provider_node = service_type_node[provider]
    if service_provider_node == nil
      service_provider_node = Tree::TreeNode.new(provider,service_hash[:service_type] + " Provider:"+ provider)
      service_type_node << service_provider_node
    end
    
    if service_provider_node[service_hash[:name]] != nil
      #FixME need to explain why
      return false
    else
      service_node = Tree::TreeNode.new(service_hash[:name],service_hash)
      service_provider_node << service_node
    end

    
 #write services tree
   
     services_node = @service_tree["Services"]
   
      
       provider_node = services_node[service_hash[:service_provider] ]
        if provider_node == nil
          provider_node = Tree::TreeNode.new(service_hash[:service_provider] ," Provider:" + service_hash[:service_provider] + ":" + service_hash[:service_type]  )
          services_node << provider_node
        end
        
        servicetype_node =  provider_node[service_hash[:service_type] ]
          if servicetype_node == nil
            servicetype_node =  Tree::TreeNode.new(service_hash[:service_type],service_hash[:service_type])
            provider_node << servicetype_node
          end
          
          service_node = servicetype_node[service_hash[:parent_engine]]
            if service_node == nil
              service_node = Tree::TreeNode.new(service_hash[:parent_engine],service_hash)
              servicetype_node << service_node
            end
    #FIXME need to handle updating service 
        

    save_tree
rescue Exception=>e
    puts e.message 
    log_exception(e)
    
  end

  def remove_service service_hash
   
      parent_engine_node = @service_tree["ManagedEngine"][service_hash[:parent_engine]]
        if parent_engine_node == nil
          @last_error ="No service record found for "+ service_hash[:parent_engine] 
          return false
        end
      service_type_node = parent_engine_node[service_hash[:service_type]]
        if service_type_node == nil
          @last_error ="No service record found for " + service_hash[:parent_engine] + ":" +  service_hash[:service_type]
          return false
        end
       service_provider_node =  service_type_node[service_hash[:service_provider]]
       if service_provider_node == nil
          @last_error ="No service record found for " + service_hash[:parent_engine] + " service_type:" +  service_hash[:service_type] + " Provider " + service_hash[:service_provider] 
          return false
        end
        service_node = service_provider_node[service_hash[:name]]
          p :really_removing
          p service_node
          p :from
          p service_provider_node
          #FIXME a method should do this in a loop
          
          if service_node != nil
            service_provider_node.remove!(service_node)
            if service_provider_node.children.count ==0
              service_type_node.remove!(service_provider_node)              
                if service_type_node.children.count ==0
                  parent_engine_node.remove!(service_type_node)
                    if parent_engine_node.children.count == 0
                      @service_tree["ManagedEngine"].remove!(parent_engine_node)
                    end
                end
            end

            
      services_node = @service_tree["Services"]
      if services_node !=nil
        provider_node = services_node[service_hash[:service_provider] ]
        if provider_node != nil
          servicetype_node =  provider_node[service_hash[:service_type] ]
          if servicetype_node != nil
            service_node = servicetype_node[service_hash[:parent_engine]]
            if service_node != nil
              servicetype_node.remove!(service_node)
              if servicetype_node.children.count == 0
                provider_node.remove!(service_node)
                if provider_node.children.count == 0
                  service_node.remove!(provider_node)
                end
              end
            end                          
          end
        end
      end
            
            
            sucess =  true
          end         
          
          if sucess == true
            save_tree
            return true
          end
          
@last_error ="No service record found for " + service_hash[:parent_engine] + " service_type:" +  service_hash[:service_type] + " Provider " + service_hash[:service_provider] + " Name " + service_hash[:name]
        return false 
          
rescue Exception=>e
  if service_hash != nil
    p service_hash
  end
  log_exception(e)    
  end

def software_service_definition(params)
  require 'json'
  
  service_filename = SysConfig.ServiceTemplateDir + "/" + params[:service_provider] + "/" + params[:service_type]+ ".yaml"
  if File.exists?(service_filename)
    yaml = File.read(service_filename)
    software_service_def  = SoftwareServiceDefinition.from_yaml(yaml)
    return software_service_def.to_h
  else
    return nil
  end

    
rescue Exception=>e
log_exception(e)
  return nil
end  


  
  
  def tree_from_yaml()
    begin
      tree_data = File.read(SysConfig.ServiceTreeFile)
#      p :tree_data
#      p tree_data
      #service_tree = Tree::TreeNode.new("Service Manager", "Managed Services and Engines")
      #service_tree = service_tree.marshal_load(tree_data)
   #   service_tree = Marshal.load(tree_data)
      service_tree =   YAML::load(tree_data)
#      p :loaded_tree
#      p service_tree

      return service_tree
    rescue Exception=>e
      puts e.message + " with " + tree_data.to_s
      log_exception(e)
    end
  end

  def save_tree
  #  serialized_object = Marshal.dump(@service_tree)
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

  def log_exception(e)
    e_str = e.to_s()
    e.backtrace.each do |bt |
      e_str += bt
    end
    @last_error = e_str
    SystemUtils.log_output(e_str,10)
  end
end