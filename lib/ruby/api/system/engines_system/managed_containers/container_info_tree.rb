module ContainerInfoTree
  def write_info_tree(ca, keys)
    unless File.exists?(ContainerStateFiles.container_info_tree_dir(ca))
      FileUtils.mkdir_p(ContainerStateFiles.container_info_tree_dir(ca))
    end
    keys.each do |k, v|
      next if v.nil?
      kf = File.new("#{ContainerStateFiles.container_info_tree_dir(ca)}/#{k}",'w')
      begin
        kf.write(v.to_s)
      ensure
        kf.close
      end
    end
  end

  def remove_info_tree(ca)
    if File.exists?(ContainerStateFiles.container_info_tree_dir(ca))
      FileUtils.rm_f(ContainerStateFiles.container_info_tree_dir(ca))
    end
  end

  def write_info_tree(ca, keys)
     unless File.exists?(ContainerStateFiles.container_info_tree_dir(ca))
       FileUtils.mkdir_p(ContainerStateFiles.container_info_tree_dir(ca))
     end
     keys.each do |k, v|
       next if v.nil?
       kf = File.new("#{ContainerStateFiles.container_info_tree_dir(ca)}/#{k}",'w')
       begin
         kf.write(v.to_s)
       ensure
         kf.close
       end
     end
   end
 
   def remove_info_tree(ca)
     if File.exists?(ContainerStateFiles.container_info_tree_dir(ca))
       FileUtils.rm_f(ContainerStateFiles.container_info_tree_dir(ca))
     end
   end

end