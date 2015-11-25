module RegistryClient
  def system_registry_client
    @system_registry = SystemRegistryClient.new(@core_api) if @system_registry.nil?
    return @system_registry
  end
end