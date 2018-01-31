module ContainerInfoTree
  def write_info_tree(c, keys)
    unless File.exists?(container_info_tree_dir(c))
      FileUtils.mkdir_p(container_info_tree_dir(c))
    end        
    keys.each do |k, v|
      kf = File.new(container_info_tree_dir(c) + '/' + k.to_s,'w')
      kf.write(v.to_s)
      kf.close
     end
  end

  def remove_info_tree(c)
    if File.exists?(container_info_tree_dir(c))
      FileUtils.rm_f(container_info_tree_dir(c))
    end
  end
  class FakeContainer
    attr_reader :container_name, :ctype
    def initialize(p)
      @container_name = p[:name]
      @ctype  = p[:ctype]   
    end
    end
    
  def init_container_info_dir(p)
    if p.is_a?(Hash)    
      c = FakeContainer.new(p)
      keys = p[:keys]
    else
      c = p
    keys = {uid: c.cont_user_id} 
    end
    
    write_info_tree(c, keys)

end
       
end