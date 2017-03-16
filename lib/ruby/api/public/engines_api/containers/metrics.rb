module PublicApiContainersMetrics
  def  container_memory_stats(container)
    MemoryStatistics.container_memory_stats(container)
  rescue StandardError => e
    handle_exception(e)
  end

  def get_container_network_metrics(container)
    container.get_container_network_metrics
  rescue StandardError => e
    handle_exception(e)
  end
end