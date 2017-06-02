module FirstRunParamsValidation
  def validate_params(first_run_params)
    return log_error('dns params failed validation') unless validate_dns_params(first_run_params)
    true
  end
end