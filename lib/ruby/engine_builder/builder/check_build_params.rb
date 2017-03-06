module CheckBuildParams
  def check_build_params(params)
    r = ''
    return r unless (r = check_name(params)).is_a?(TrueClass)
    return r unless (r = check_host(params)).is_a?(TrueClass)    
    return true
  rescue StandardError => e
    log_exception(e)
  end
  
 # private 
  
  def check_host(params)
 #   return bad_param('Missing: Hostname', params) unless params.key?(:host_name)
 #    return bad_param('Invalid: Hostname', params) unless acceptable_chars(params[:host_name])
    return true
  end
  
  def check_name(params)
 #    return bad_param('Missing: Engine Name', params) unless params.key?(:engine_name)
  #  return bad_param('Invalid: Engine Name', params) unless acceptable_chars(params[:engine_name])
    return true
  end
  
  def bad_param(message, params)
  # FIXMe use a builderror 
    return EnginesError.new(message,:error,'builder')
  end
  
  def acceptable_chars(str)
    return false if str.nil?
    return false if str.match(/^[0-9]/)
    return true if str.match(/^[a-zA-Z0-9]+$/)
    return false
  end
end