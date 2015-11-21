module ManagedServiceContainerInfo
  
  def check_cont_uid
     if @cont_userid.nil? || @cont_userid == false  || @cont_userid == ''
       @cont_userid = running_user
       if @cont_userid.nil? || @cont_userid == false
         log_error_mesg('service missing cont_userid ',@container_name)
         return false
       end
     end
     return true
   end
end