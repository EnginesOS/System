module PublicApiContainers
  # @return [Array]
  #  get Array of containers with changed state changed
  def get_changed_containers
    @system_api.get_changed_containers
  rescue StandardError => e
    handle_exception(e)
  end

  def  containers_check_and_act
    @system_api.containers_check_and_act
  rescue StandardError => e
    handle_exception(e)
  end
end