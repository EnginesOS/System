class PermissionRights
  def initialize(owner,ro_group,rw_group)
    @owner = owner
    @ro_group =  ro_group
    @rw_group =rw_group
  end
  
  def owner
    return @owner
  end
  
  def ro_group
    return @ro_group
  end
  def rw_group
    return @rw_group
  end
   
end