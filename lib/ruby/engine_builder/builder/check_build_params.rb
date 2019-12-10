module CheckBuildParams
  def check_build_params(memento)
    raise EngineBuilderException.new(error_hash('empty container name', memento.container_name)) if memento.container_name.nil? 
    check_name(memento.container_name)
    check_host(memento.hostname)
    true
  end

  private

  def check_host(name)
    bad_param('Invalid: hostname.', params) unless acceptable_host_chars(name)
  end

  def check_name(name)
    bad_param('Invalid characters in engine name a-z only.', params) unless acceptable_name_chars(name, true)
  end

  def bad_param(message, params)
    # FIXMe use a builderror
    SystemStatus.build_failed(params)
    raise EngineBuilderException.new(warning_hash(message, params))
  end

  def acceptable_name_chars(str, lower = false)
    return true
    #FIX ME
    def match_lower(str,lower)
      if lower == true
        if str.match(/^[a-z]+$/).nil? || str.match(/[a-z0-9]+$/).nil?
          STDERR.puts(' failed to match ' + str + ' r  ' +   str.match(/^[a-z]+$/).to_s + ' r2 ' + str.match(/[a-z0-9]+$/).to_s)
          false
        else
          STDERR.puts('matched ' + str + ' r  ' +   str.match(/^[a-z]+$/).to_s + ' r2 ' + str.match(/[a-z0-9]+$/).to_s)
          #FIXME
          true
          #false
        end
      else
        if str.match(/^[a-zA-Z]/).nil? || str.match(/[a-zA-Z0-9]+$/, 1).nil?
          false
        else
          true
        end
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