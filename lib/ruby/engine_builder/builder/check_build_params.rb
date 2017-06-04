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
    bad_param('Invalid: Engine Name', params) unless acceptable_name_chars(params[:engine_name])
  end

  def bad_param(message, params)
    # FIXMe use a builderror
    SystemStatus.build_failed(params)
    raise EngineBuilderException.new(error_hash(message, params))
  end
  def acceptable_name_chars(str)
      return false if str.nil?
      return false unless str.match(/^[a-zA-Z]/)
      return true if str.match(/^[a-zA-Z0-9_]+$/)
      false
    end
  def acceptable_host_chars(str)
    return false if str.nil?
    return false unless str.match(/^[a-zA-Z]/)
    return true if str.match(/^[a-zA-Z0-9-]+$/)
    false
  end
end