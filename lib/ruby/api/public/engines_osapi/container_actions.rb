module ContainerActions
  def get_container_network_metrics(container_name)
    @core_api.get_container_network_metrics(container_name)
  rescue StandardError => e
    log_exception_and_fail('get_container_network_metrics', e)
  end
end