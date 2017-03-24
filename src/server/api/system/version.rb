require '/opt/engines/lib/ruby/api/system/system_status.rb'

# @!group /system/version
#
# @method get_system_version_release
# @overload get '/v0/system/version/release'
#  as in current|master|beta-rc etc
# @return  [String]  as in current|master|beta-rc etc

get '/v0/system/version/release' do
  begin
    return_text(SystemStatus.get_engines_system_release)
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

# @method get_system_version_api
# @overload get '/v0/system/version/api'
# api version
# @return [String] api version
#

get '/v0/system/version/api' do
  begin
    return_text(engines_api.api_version)
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

# @method get_system_version_ident
# @overload get '/v0/system/version/ident'
#
# @return [String] $release-$system-$api
#  string format $release-$system-$api
get '/v0/system/version/ident' do
  begin
    return_text(engines_api.version_string)
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

# @method get_system_version_system
# @overload get '/v0/system/version/system'
#
# @return [String] system version
# system version
get '/v0/system/version/system' do
  begin
    return_text(engines_api.system_version)
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

require '/opt/engines/lib/ruby/system/system_utils.rb'

# @method get_system_version_base_os
# @overload get '/v0/system/version/base_os'
# @return [Hash] :name :version :id :id_like :pretty_name :version_id :home_url :support_url :bug_report_url
# keys set by OS
get '/v0/system/version/base_os' do
  begin
    base_os = downcase_keys(SystemUtils.get_os_release_data)
    return_json(base_os)
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

# @!endgroup
