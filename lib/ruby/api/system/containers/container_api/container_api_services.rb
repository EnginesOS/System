module ContainerApiServices
  #
  # @param match [Hash]
  # @param container [ManagedContainer]
  def container_services(ca, match)
    match[:parent_engine] = ca[:c_name]
    match[:container_type] = ca[:c_type]
    core.find_engine_services(match)
  rescue EnginesException => e
    {}
  end
end
