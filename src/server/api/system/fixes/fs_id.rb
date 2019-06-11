# @!group /system/fixes/
# @method fix_containers_fsid
# @overload get '/v0/system/fixes/fs_id'
# runs the fs_id fixes met to set fs_user in fs reg entries
# @return [String] 
get 'v0/system/fixes/fs_id' do
  begin
    return_text(engines_api.fix_containers_fsid)
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end