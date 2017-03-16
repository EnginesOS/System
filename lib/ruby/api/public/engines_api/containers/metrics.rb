module PublicApiContainersMetrics
  def  container_memory_stats(container)
    MemoryStatistics.container_memory_stats(container)
  end

  def get_container_network_metrics(container)
    container.get_container_network_metrics
  end
end