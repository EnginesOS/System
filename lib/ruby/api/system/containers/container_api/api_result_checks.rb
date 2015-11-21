module ApiResultChecks
  def test_docker_api_result(result)
    @last_error = @docker_api.last_error if result == false || result.nil?
    return result
  end

  def test_system_api_result(result)
    @last_error = @system_api.last_error if result == false || result.nil?
    return result
  end

end