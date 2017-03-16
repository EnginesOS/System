module PublicApiServiceDefinitions
  def get_service_definition(params)
    SoftwareServiceDefinition.software_service_definition(params)
  rescue StandardError => e
    handle_exception(e)
  end

end