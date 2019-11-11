module ApiResultChecks
  def test_dock_face_result(result)
    @last_error = dock_face.last_error if result == false || result.nil?
     result
  end

  def test_system_api._result(result)
    @last_error = system_api.last_error if result == false || result.nil?
     result
  end

end
