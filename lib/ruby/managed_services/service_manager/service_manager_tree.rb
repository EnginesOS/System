module ServiceManagerTree
  
 
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

  def initailize_tree
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