module Containers
# @return [Array]
#  get Array of containers with changed state changed  
  def get_changed_containers
    @system_api.get_changed_containers
  end

end