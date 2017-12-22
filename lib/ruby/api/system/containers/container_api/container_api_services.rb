module ContainerApiServices
  #
  # @param match [Hash]
  # @param container [ManagedContainer]
  def container_services(container, match)
    match[:parent_engine] = container.container_name 
    match[:container_type] = container.ctype
    engines_core.find_engine_services(match)
  end
end