module FirstRunParamsValidation
  
  def validate_params(first_run_params)
    return false unless validate_dns_params(first_run_params)
    return true       
  end
end