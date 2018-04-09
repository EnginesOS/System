module CheckBuildParams
  def check_build_params(params)
    raise EngineBuilderException.new(error_hash('empty container name', params)) if params[:engine_name].nil? || params[:engine_name] == ''
    check_name(params)
    check_host(params)
    true
  end

  # private

  def check_host(params)
    bad_param('Missing: Hostname', params) unless params.key?(:host_name)
    bad_param('Invalid: Hostname', params) unless acceptable_host_chars(params[:host_name])
  end

  def check_name(params)
    bad_param('Missing: Engine Name', params) unless params.key?(:engine_name)
    bad_param('Invalid characters in Engine Name a-z only', params) unless acceptable_name_chars(params[:engine_name], true)
  end

  def bad_param(message, params)
    # FIXMe use a builderror
    SystemStatus.build_failed(params)
    raise EngineBuilderException.new(error_hash(message, params))
  end


  
  def acceptable_name_chars(str, lower = false)
    def match_lower(str,lower)
      if lower == true  
        str.match(/^[a-z]+$/) & str.match(/[a-z0-9]+$/)
      else
      str.match(/^[a-zA-Z]/) & str.match(/[a-zA-Z0-9]+$/)
      end        
   end
   
    if str.nil?
      false
    elsif match_lower(str, lower) 
      true
    else
      false
    end
  end

  def acceptable_host_chars(str)
    if str.nil?
      false
    elsif str.match(/^[a-zA-Z]/) && str.match(/[a-zA-Z0-9-]+$/)
      true
    else
      false
    end
  end
end