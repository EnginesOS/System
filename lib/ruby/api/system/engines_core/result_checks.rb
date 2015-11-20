module ResultChecks
  def test_docker_api_result(result)
    @last_error = @docker_api.last_error if result.nil? || result.is_a?(FalseClass)
    return result
  end

  def test_system_api_result(result)
    @last_error = @system_api.last_error.to_s if result.is_a?(FalseClass)
    return result
  end

  def check_sm_result(result)
    @last_error = service_manager.last_error.to_s  if result.nil? || result.is_a?(FalseClass)
    return result
  end

end