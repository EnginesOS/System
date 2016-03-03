module ApiActionators
  @@action_timeout = 20
  
# def perform_action(constainer, actionator_name, params)
#   SystemDebug.debug(SystemDebug.actions,constainer.container_name, actionator_name, params)
#  cmd ='docker exec /home/actionators/' + actionator_name.to_s + ' ' + list_params(params).to_s
#
#  if @docker_api.run_docker_cmd(cmd, constainer)
#    SystemDebug.debug(SystemDebug.actions,'perform_action',cmd,container.last_result)
#   return container.last_result
#  else
#    @last_error  = container.last_error 
#    SystemDebug.debug(SystemDebug.actions,'perform_action',container.last_error)
#    return false
#  end
#  
#  
#end


  def perform_action(c,actionator_name, params)
      # cmd = 'docker exec -u ' + c.cont_userid + ' ' +  c.container_name + ' /home/configurators/read_' + params[:configurator_name].to_s + '.sh '
      cmd = 'docker exec  ' +  c.container_name + ' /home/actionators/' + actionator_name + '.sh ' + list_params(params).to_s
      result = {}
      begin
        Timeout.timeout(@@action_timeout) do
          thr = Thread.new { result = SystemUtils.execute_command(cmd) }
          thr.join
        end
      rescue Timeout::Error
        log_error_mesg('Timeout on Running Action ',cmd)
        return {}
      end
  
      if result[:result] == 0
        #variables = SystemUtils.hash_string_to_hash(result[:stdout])
#        variables_hash = JSON.parse( result[:stdout], :create_additons => true )
#        params[:variables] = SystemUtils.symbolize_keys(variables_hash)      
        return result[:stdout]
      end
      log_error_mesg('Error on retrieving Configuration',result)
    @last_error = c.last_error 
      return false
    end



def list_params(params)
  return ' ' if params.nil?
  r = ' '
   params.each do |param|
     r += param.to_s + ' '
   end
   return r
end

end