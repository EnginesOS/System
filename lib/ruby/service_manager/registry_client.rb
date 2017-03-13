module RegistryClient
  def system_registry_client
    @system_registry ||= SystemRegistryClient.new(@core_api)
  end
end