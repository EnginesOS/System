#test the result and carry last_error from system_registry_client if result nil
#@return result
def test_registry_result(result)

  log_error_mesg(system_registry_client.last_error, result) if result.is_a?(EnginesError)
  return result
rescue StandardError => e
  log_exception(e)
end

def test_subservices_result(result)

  log_error_mesg(@subservices_registry.last_error, result) if result.is_a?(EnginesError)
  return result
rescue StandardError => e
  log_exception(e)
end

#test the result and carry last_error from system_registry_client if nil
#freeze result object if not nil
#@return result
def test_and_lock_registry_result(result)
  if test_registry_result(result)
    result.freeze
  end
  return result
end   