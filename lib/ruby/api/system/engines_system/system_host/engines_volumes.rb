class SystemApi
  def volume_ownership(params)
    path = "#{SystemConfig.LocalFSVolHome}/#{params[:container_name]}/#{params[:volume_name]}"
    if Dir.exits?(path)
      File.stat(path).uid
    else
      -1
    end
  rescue StandardError =>e
    STDERR.puts('volume ownership ' + e.to_s)
    -1
  end
end