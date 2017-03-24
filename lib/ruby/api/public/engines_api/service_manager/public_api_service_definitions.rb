module PublicApiServiceDefinitions
  def get_service_definition(params)
    SoftwareServiceDefinition.software_service_definition(params)
  end

end