class PublicApi 

def set_user_password(params)
  ldap = bind_as_user(params[:user_name])
    #set_user_password returns json for the gui to consume
    set_user_password(ldap, params)
    '{"result":"ok"}'
end 
 
  def is_admin_token_valid?(token, ip = nil)
    core.is_admin_token_valid?(token, ip = nil)
  end
def bind_as_user(params)
  
end

def set_user_password(ldap, params)
  
end


end