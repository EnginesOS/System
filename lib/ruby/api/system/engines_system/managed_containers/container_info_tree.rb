module ContainerInfoTree
  def write_info_tree(c)
    unless File.exists?(container_info_tree_dir(c))
      FileUtils.mkdir_p(container_info_tree_dir(c))
    end    
    uid_f = File.new(container_info_tree_dir(c) + '/uid','w')
    uid_f.write(c.cont_userid.to_s)
    uid_f.close    
  end
end