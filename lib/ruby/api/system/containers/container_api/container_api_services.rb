module ContainerApiServices
  #
  # @param match [Hash]
  # @param container [ManagedContainer]
  def engine_services(container, match)
    match[:parent_engine] = container.container_name 
    engines_core.find_engine_services(match)
  end
end