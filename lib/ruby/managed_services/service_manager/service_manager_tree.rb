module ServiceManagerTree
  
  def managed_engine_tree
        return @service_tree["ManagedEngine"]
    end
  
    def get_managed_engine_tree
      return managed_engine_tree
  end

    def orphaned_services_tree
      orphans = @service_tree["OphanedServices"]
                if orphans == nil
                  @service_tree << Tree::TreeNode.new("OphanedServices","Persistant Services left after Engine Deinstall")
                  orphans = @service_tree["OphanedServices"]
                end
                
                return orphans
    end
    
    def get_orphaned_services_tree
      return orphaned_services_tree
    end
    
  def managed_service_tree 
    return @service_tree["Services"]
  end
    
  
  def remove_tree_entry(tree_node)
    if tree_node == nil || tree_node.is_a?(TreeNode) == false
      P :err_remove_tree_entry
      p tree_node.to_s
      return false
    end
  
    if tree_node.parent == nil
      return false
    end
    
    parent_node = tree_node.parent
    parent_node.remove!(tree_node)
      if parent_node.has_children == false
        remove_tree_entry(parent_node)
      end
      
      return true
  end
  
  
  def get_matched_leafs(branch,label,value)
    ret_val = Array.new
    branch.children.each do |sub_branch|
           if sub_branch.children.count == 0
              if  sub_branch.content[label] == value 
                  ret_val.push(sub_branch.content)  
              end
           else
          ret_val += get_matched_leafs(sub_branch,label,value) 
       end
    end
       return ret_val
  end
  
  
  def tree_from_yaml()
    begin
      tree_data = File.read(SysConfig.ServiceTreeFile)
      service_tree =   YAML::load(tree_data)
      return service_tree
    rescue Exception=>e
      puts e.message + " with " + tree_data.to_s
      SystemUtils.log_exception(e)
    end
  end

  def initialize_tree
    if File.exists?(SysConfig.ServiceTreeFile)
          service_tree = tree_from_yaml()
        else
          service_tree = Tree::TreeNode.new("Service Manager", "Managed Services and Engines")
          service_tree << Tree::TreeNode.new("ManagedEngine","Engines")
          service_tree << Tree::TreeNode.new("Services","Managed Services")
        end
        
        return service_tree
        rescue Exception=>e
            puts e.message 
        SystemUtils.log_exception(e)
            
  end
  
def get_service_provider_tree(publisher)
    managed_service_tree[publisher]
  end
  
  protected
  
  def save_tree
  #  serialized_object = Marshal.dump(@service_tree)
    serialized_object = YAML::dump(@service_tree)
    f = File.new(SysConfig.ServiceTreeFile,File::CREAT|File::TRUNC|File::RDWR, 0644)
    f.puts(serialized_object)
    f.close
    return true
  rescue Exception=>e
    @last_error=( "load error")
    SystemUtils.log_exception(e)
    return false
  end

end