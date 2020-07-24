class SystemApi
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

#  class FakeContainer
#    attr_reader :container_name, :ctype
#    def initialize(p)
#      @container_name = p[:name]
#      @ctype  = p[:ctype]
#    end
#  end

#  def init_container_info_dir(p)
#    if p.is_a?(Hash)
#    ca = {c_type: p[:ctype], c_name: p[:c_name]}      
#      keys = p[:keys]
#    else
#      c = p
#      ca = {c_type: c.ctype, c_name: c.container_name} 
#      keys = {uid: c.cont_user_id}
#    end
#    write_info_tree(ca, keys)
#  end

end