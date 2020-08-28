class PublicApi 
  def user_login(params)
    core.user_login(params)
  end
  def log_out_user(cparams)
    core.log_out_user(params[:user_toke])
  end

  def set_system_user_password(params)
    STDERR.puts(" set_system_user_password(#{params[:new_password]},  #{params[:token]}, #{params[:current_password]}) ")
    core.set_system_user_password(params[:new_password],  params[:token], params[:current_password] )
  end

  def get_system_user_info(cparams)
    core.get_system_user_info(cparams[:user_name])
  end

  def set_system_user_details(cparams)
    core.set_system_user_details(cparams)
  end

  def set_system_user_settings(cparams)
    core.set_system_user_settings(cparams)
  end

  def system_user_settings()
    core.system_user_settings()
  end
end
