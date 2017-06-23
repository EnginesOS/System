module UserAuth
  def user_login(params)
    @core_api.user_login(params)
  end
  
 def set_system_user_password(params)
   @core_api.set_system_user_password(params[:user_name], params[:new_password], params[:email], params[:token], params[:current_password] )
 end
end