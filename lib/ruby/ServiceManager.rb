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
    rescue Exception=>e
        puts e.message 
        log_exception(e)
        
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

  def attached_managed_engine_services(identifier)
    #@service_tree = tree_from_yaml()
    p :attached_managed_engine_services
    p @service_tree
    retval = Hash.new

    if identifier == nil
      p :panic_passed_nil_identifier
      return retval
    end
    @service_tree = tree_from_yaml()
    if @service_tree == nil
      p :panic_loaded_nil_tree
      return retval
    end

    engines_node =  @service_tree["ManagedEngine"]
    if  engines_node ==nil
      p :panic_loaded_managedengine_tree
      return retval
    end

    engine_node =engines_node[identifier]
    p :engine_node
     engine_node.print_tree
    if engine_node == nil
      p :cant_find
      p identifier
      return retval
    end

    engine_node.each do |service|

      st = service.content["Services"]
      p :service_type
      p st
      if st == nil
        p :no_service_type
        return retval
      end
      if retval.has_key?(st) == false
        retval[st] = Array.new
      end
      retval[st].push(service.content)
    end
    p :retval
    p retval
    return retval
 
rescue Exception=>e
    puts e.message 
    log_exception(e)
    
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

    if active_engines_node[service_hash[:parent_engine] ] != nil
      engine_node = active_engines_node[ service_hash[:parent_engine] ]
    else
      engine_node = Tree::TreeNode.new(service_hash[:parent_engine],service_hash[:parent_engine] + " Engine Service Tree")
      active_engines_node << engine_node
    end
    
    services_node = engine_node[ "Services" ]
      
    if services_node == nil
      services_node = Tree::TreeNode.new("Services","Services for " + service_hash[:parent_engine] )
      engine_node <<  services_node
    end
    
    service_type_node = services_node[service_hash[:service_type]]
      
     if service_type_node == nil
      service_type_node = Tree::TreeNode.new(service_hash[:service_type], service_hash[:service_type] + " Service")
       services_node << service_type_node       
    end
    
    provider = service_hash[:service_provider]
     if provider == nil || provider.count ==0
       provider="Engines"
     end
     
    service_provider_node = service_type_node[provider]
    if service_provider_node == nil
      service_provider_node = Tree::TreeNode.new(provider,service_hash[:service_type] + " Provider:"+ provider)
      service_type_node << service_provider_node
    end
    
    if service_provider_node[service_hash[:service_type]] != nil
      #FixME need to explain why
      return false
    else
      service_node = Tree::TreeNode.new(service_hash[:service_type],service_hash)
      service_provider_node << service_node
    end

    
 #write services tree
   
     services_node = @service_tree["ManagedService"]
    
    
        servicetype_node =  services_node[service_hash[:service_type] ]
          if servicetype_node == nil
            servicetype_node =  Tree::TreeNode.new(service_hash[:service_type],service_hash[:service_type])
            services_node << servicetype_node
          end
          provider_node = servicetype_node[provider]
            if provider_node == nil
              provider_node = Tree::TreeNode.new(provider,service_hash[:service_type] + " Provider:"+ provider)
              servicetype_node << provider_node
            end
    
          servicetype_node  = Tree::TreeNode.new(service_hash[:parent_engine],service_hash)

    save_tree
rescue Exception=>e
    puts e.message 
    log_exception(e)
    
  end

  def remove_service service_hash
    save_tree
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