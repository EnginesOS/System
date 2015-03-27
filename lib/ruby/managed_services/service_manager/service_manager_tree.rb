module ServiceManagerTree
  # Module of Methods to handle tree structure for ServiceManager
  
  # @return the ManagedEngine Tree Branch
  # @creates if does not exist
  def managed_engine_tree
    if (@service_tree["ManagedEngine"] == nil )
      @service_tree << Tree::TreeNode.new("ManagedEngine","ManagedEngine Service register")       
    end
    return @service_tree["ManagedEngine"]
  end

   #@return The OrphanedServices Tree branch
   # create new branch if none exists
  def orphaned_services_tree
    orphans = @service_tree["OphanedServices"]
    if orphans == nil
      @service_tree << Tree::TreeNode.new("OphanedServices","Persistant Services left after Engine Deinstall")
      orphans = @service_tree["OphanedServices"]
    end

    return orphans
  end
  
  # @return the ManagedServices Tree Branch
   #  creates if does not exist
  def managed_service_tree
    if (@service_tree["Services"] == nil )
       @service_tree << Tree::TreeNode.new("ManagedEngine","ManagedEngine Service register")       
     end
     return @service_tree["Services"]
    
  end

  def remove_tree_entry(tree_node)
    # @param remove [TreeNode] from the @servicetree
    # If the tree_node is the last child then the parent is removed this is continued up.  
    if tree_node == nil || tree_node.is_a?(Tree::TreeNode ) == false
      p :err_remove_tree_entry

      return false
    end

    if tree_node.parent == nil
      return false
    end

    parent_node = tree_node.parent
    parent_node.remove!(tree_node)
    if parent_node.has_children? == false
      remove_tree_entry(parent_node)
    end

    return true
  end

  #@return [Array] all service_hash(s) which contain the hash pair label=value    
  #@returns empty array if none
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
  
# @return [Array] all service_hash(s) below this branch
  def get_all_leafs_service_hashes(branch)
    ret_val = Array.new
    branch.children.each do |sub_branch|
      if sub_branch.children.count == 0
        if sub_branch.content.is_a?(Hash)

          SystemUtils.debug_output("pushed_content", sub_branch.content)
          ret_val.push(sub_branch.content)
        else
          SystemUtils.debug_output("skipping content ", sub_branch.content)
        end
      else
        ret_val.concat(get_all_leafs_service_hashes(sub_branch))
      end
    end
    return ret_val
  end

  #@loads the Service tree off disk from [SysConfig.ServiceTreeFile]
  #@ calls [SystemUtils.log_exception] on error and returns nil 
  def tree_from_yaml()
    begin
      tree_data = File.read(SysConfig.ServiceTreeFile)
      service_tree =   YAML::load(tree_data)
      return service_tree
    rescue Exception=>e
      puts e.message + " with " + tree_data.to_s
      SystemUtils.log_exception(e)
      return nil
    end
  end

  #@ Load tree from file or create initial service tree
  #@returns ServiceTree as a [TreeNode]
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

  #@Wrapper for Gui to be removed
  def service_provider_tree(publisher)
    managed_service_tree[publisher]
  end

  protected
#@saves the Service tree to disk at [SysConfig.ServiceTreeFile] and returns tree  
#@ calls [SystemUtils.log_exception] on error and returns false 
  def save_tree
    
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