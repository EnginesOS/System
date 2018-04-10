module UserAuth

def set_user_password(params)
  ldap = bind_as_user(params[:user_name])
    #set_user_password returns json for the gui to consume
    set_user_password(ldap, params)
    '{"result":"ok"}'
end 
 
def bind_as_user(params)
  
end

def set_user_password(ldap, params)
  
end


end