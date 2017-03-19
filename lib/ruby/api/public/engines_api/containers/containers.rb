module PublicApiContainers
  # @return [Array]
  #  get Array of containers with changed state changed
  def get_changed_containers
    @system_api.get_changed_containers
  end

  def containers_check_and_act
    @system_api.containers_check_and_act
  end
end