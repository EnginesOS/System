module TemplateActions
  # @ returns [SoftwareServiceDefinition] with TEmplating evaluated
  # requires keys :type_path and 'publisher_namespace :parent_engine
  def get_resolved_service_definition(service_hash)
    @core_api.fillin_template_for_service_def(service_hash)
  end

  def get_resolved_string(env_value)
    return @core_api.get_resolved_string(env_value)
  end

  def templated_software_service_definition(params)
    # ret_val = software_service_definition(params)
    @core_api.fillin_template_for_service_def(params)
  end

end