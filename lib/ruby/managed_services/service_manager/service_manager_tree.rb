# Module of Methods to handle tree structure for ServiceManager
module ServiceManagerTree
  @last_read
  
  # @return the ManagedEngine Tree Branch
  # creates if does not exist
  def managed_engine_tree
    if check_service_tree == false
          return false
        end
    if (service_tree["ManagedEngine"] == nil )
      service_tree << Tree::TreeNode.new("ManagedEngine","ManagedEngine Service register")       
    end
    return service_tree["ManagedEngine"]
    rescue Exception=>e
         log_exception(e)
         return nil
  end
  
  
  def service_tree
  
   current_time = File.mtime(SysConfig.ServiceTreeFile)
     if (@last_tree_mod_time <=> current_time ) != 0
       load_tree
     end
     
    return @service_tree
  end

    #@return The OrphanedServices Tree [TreeNode] branch
   # create new branch if none exists
  def orphaned_services_tree
    p :orphan_tree
    if check_service_tree == false 
          return false
        end
    orphans = service_tree["OphanedServices"]
    if orphans == nil
      service_tree << Tree::TreeNode.new("OphanedServices","Persistant Services left after Engine Deinstall")
      orphans = service_tree["OphanedServices"]
    end

    return orphans
    rescue Exception=>e
         log_exception(e)
         return nil
  end
  
  #@return the ManagedServices Tree [TreeNode] Branch
   #  creates if does not exist
  def managed_service_tree
    p :service_manager_
    p :managed_service_tree
    if check_service_tree == false
      return false
    end
    if (service_tree["Services"] == nil )
       service_tree << Tree::TreeNode.new("Services"," Service register")       
     end
   
     return service_tree["Services"]
       
    rescue Exception=>e
         log_exception(e)
         return nil
  end

  # param remove [TreeNode] from the @servicetree
  # If the tree_node is the last child then the parent is removed this is continued up.
  #@return boolean  
  def remove_tree_entry(tree_node)

   
    if tree_node == nil || tree_node.is_a?(Tree::TreeNode ) == false
      log_error_mesg("Nil treenode ?",tree_node)      
      return false
    end

    if tree_node.parent == nil
      log_error_mesg("No Parent Node ! on remove tree entry",tree_node)
      return false
    end

    parent_node = tree_node.parent
    parent_node.remove!(tree_node)
    if parent_node.has_children? == false
      remove_tree_entry(parent_node)
    end

    return save_tree
    rescue Exception=>e
         log_exception(e)
         return false
  end
  
  #@return boolean true if not nil
  def    check_service_tree
    if service_tree == nil || service_tree == false
      SystemUtils.log_error_mesg("Nil service tree ?",service_tree)
      return false
    end
    return true
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
  
  #@branch the [TreeNode] under which to search
  #@param label the hash key for the value to match value against
  #@return [Array] all service_hash(s) which contain the hash pair label=value    
  #@return empty array if none
  def get_matched_leafs(branch,label,value)
    ret_val = Array.new
    branch.children.each do |sub_branch|
      if sub_branch.children.count == 0
        if sub_branch.content.is_a?(Hash) 
          if  sub_branch.content[label] == value
            ret_val.push(sub_branch.content)
#            p :push_match_leaf
#            p   sub_branch.content
#        else
#          p " did not match" + sub_branch.content.to_s + " with  "  + label.to_s + ":" + value.to_s                     
          end
        else
         SystemUtils.debug_output("Leaf Content not a hash ",sub_branch.content)
           end
      else #children.count > 0
        ret_val.concat(get_matched_leafs(sub_branch,label,value))
      end #if children.count == 0
    end #do
    return ret_val
  rescue Exception=>e
       log_exception(e)
       return nil
  end
  
# @return [Array] of all service_hash(s) below this branch
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
    rescue Exception=>e
         log_exception(e)
         return nil
  end

  #loads the Service tree off disk from [SysConfig.ServiceTreeFile]
  #calls [log_exception] on error and returns nil 
  #@return service_tree [TreeNode]
  def tree_from_yaml()
    begin
      tree_data = File.read(SysConfig.ServiceTreeFile)
      service_tree =   YAML::load(tree_data)
      return service_tree
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
      load_tree
    else
      @service_tree = Tree::TreeNode.new("Service Manager", "Managed Services and Engines")
      @service_tree << Tree::TreeNode.new("ManagedEngine","Engines")
      @service_tree << Tree::TreeNode.new("Services","Managed Services")
    end

    return service_tree
  rescue Exception=>e
    puts e.message
    log_exception(e)

  end

  
  
#@returns [TreeNode] under parent_node with the Directory path (in any) in type_path convert to tree branches
 #@return nil on error
 #@param parent_node the branch to search under
 #@param type_path the dir path format as in dns or database/sql/mysql
 def get_type_path_node(parent_node,type_path)
   if type_path == nil || parent_node == nil
     log_error_mesg("get_type_path_node_passed_a_nil path:" + type_path.to_s , parent_node.to_s)
     return nil
   end
   p :get_type_path_node
   p type_path.to_s
   if type_path.include?("/") == false
     return parent_node[type_path]

   else
     sub_paths= type_path.split("/")
     sub_node = parent_node
     sub_paths.each do |sub_path|
       sub_node = sub_node[sub_path]
       if sub_node == nil
         log_error_mesg("Subnode not found for " + type_path + "under node ", parent_node)
         return nil
       end
     end
     return sub_node
   end
rescue Exception=>e
     log_exception(e)
     return nil
   
 end
  
  #Wrapper for Gui to 
 #@return [TreeNode] managed_service_tree[publisher]
  def service_provider_tree(publisher)
    managed_service_tree[publisher]
  end
  
#Wrapper for Gui to be removed
#Should use managed_engine_tree
#@return [TreeNode] 
def get_managed_engine_tree
    return managed_engine_tree
  end
  
def log_exception(e)
   @last_error = e.to_s
   SystemUtils.log_exception(e)
 end
  
#@sets the service_tree and loast mod time 
 def load_tree
    @service_tree = tree_from_yaml()
    @last_tree_mod_time = File.mtime(SysConfig.ServiceTreeFile)
     p :loaded_service_tree
 end
 
  protected
  

#saves the Service tree to disk at [SysConfig.ServiceTreeFile] and returns tree  
# calls [log_exception] on error and returns false
  #@return boolean 
  def save_tree
    if File.exists?(SysConfig.ServiceTreeFile)
      statefile_bak = SysConfig.ServiceTreeFile + ".bak"
      File.rename( SysConfig.ServiceTreeFile,   statefile_bak)
    end
    serialized_object = YAML::dump(@service_tree)
    f = File.new(SysConfig.ServiceTreeFile,File::CREAT|File::TRUNC|File::RDWR, 0644)
    f.puts(serialized_object)
    f.close
    @last_tree_mod_time = File.mtime(SysConfig.ServiceTreeFile)
    return true
  rescue Exception=>e
    @last_error=( "load error")
    log_exception(e)
    return false
  end
  
 
end
