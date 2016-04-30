require '/opt/engines/lib/ruby/api/system/system_status.rb'

get '/v0/system/version/release' do
  SystemDebug.debug(SystemDebug.server, :release)
  release = SystemStatus.get_engines_system_release
  SystemDebug.debug(SystemDebug.server, :release,release)
  unless release.is_a?(FalseClass)
    return release.to_json
  else
    return log_error(request, release)
  end
end

get '/v0/system/version/api' do
  api = @@engines_api.api_version
  unless api.is_a?(FalseClass)
    return api.to_json
  else
    return log_error(request, api)
  end
end

get '/v0/system/version/ident' do
  ident = @@engines_api.version_string
  unless ident.is_a?(FalseClass)
    return ident.to_json
  else
    return log_error(request, ident)
  end
end

get '/v0/system/version/system' do
  system = @@engines_api.system_version
  unless system.is_a?(FalseClass)
    return system.to_json
  else
    return log_error(request, system)
  end
end

require '/opt/engines/lib/ruby/system/system_utils.rb'

get '/v0/system/version/base_os' do
  base_os = SystemUtils.get_os_release_data
  unless base_os.is_a?(FalseClass)
    return base_os.to_json
  else
    return log_error(request, base_os)
  end
end

