require '/opt/engines/lib/ruby/api/system/system_status.rb'

# @!group System Version
#
# @method get_system_version_release
# @overload get '/v0/system/version/release'
#
# @return [String]
#  as in current|master|beta-rc etc
get '/v0/system/version/release' do
  release = SystemStatus.get_engines_system_release
  unless release.is_a?(EnginesError)
    status(202)
    return release.to_json
  else
    return log_error(request, release)
  end
end

# @method get_system_version_api
# @overload get '/v0/system/version/api'
# api version 
# @return [String]
#

get '/v0/system/version/api' do
  api = engines_api.api_version
  unless api.is_a?(EnginesError)
    status(202)
    return api.to_json
  else
    return log_error(request, api)
  end
end

# @method get_system_version_ident
# @overload get '/v0/system/version/ident'
#
# @return [String]
#  string format $release-$system-$api
get '/v0/system/version/ident' do
  ident = engines_api.version_string
  unless ident.is_a?(EnginesError)
    status(202)
    return ident.to_json
  else
    return log_error(request, ident)
  end
end

# @method get_system_version_system
# @overload get '/v0/system/version/system'
#
# @return [String]
# system version 
get '/v0/system/version/system' do
  system = engines_api.system_version
  unless system.is_a?(EnginesError)
    status(202)
    return system.to_json
  else
    return log_error(request, system)
  end
end

require '/opt/engines/lib/ruby/system/system_utils.rb'

# @method get_system_version_base_os
# @overload get '/v0/system/version/base_os'
#
# @return [hash]
# keys set by OS
#  :NAME :VERSION :ID :ID_LIKE :PRETTY_NAME :VERSION_ID :HOME_URL :SUPPORT_URL :BUG_REPORT_URL
get '/v0/system/version/base_os' do
  base_os = SystemUtils.get_os_release_data

  unless base_os.is_a?(EnginesError)
    status(202)
    return base_os.to_json
  else
    return log_error(request, base_os)
  end
end

# @!endgroup