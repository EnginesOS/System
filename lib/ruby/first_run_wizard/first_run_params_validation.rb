module FirstRunParamsValidation
  def validate_params(first_run_params)
    unless validate_dns_params(first_run_params)
      log_error('dns params failed validation')
    else
      true
    end
  end
end