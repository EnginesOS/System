class PermissionRights
  def initialize(owner,ro_group,rw_group)
    @owner = owner
    @ro_group =  ro_group
    @rw_group =rw_group
  end
  
  attr_reader :owner,:ro_group,:rw_group
  

   
end