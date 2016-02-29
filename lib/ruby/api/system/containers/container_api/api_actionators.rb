module ApiActionators
 def perform_action(constainer, actionator_name, params)
   SystemDebug.debug(SystemDebug.actions,constainer.container_name, actionator_name, params)
  cmd ='docker exec /home/actionators/' + actionator_name.to_s + ' ' + list_params(params).to_s

  if @docker_api.run_docker_cmd(cmd, constainer)
    SystemDebug.debug(SystemDebug.actions,'perform_action',cmd,container.last_result)
   return container.last_result
  else
    @last_error  = container.last_error 
    SystemDebug.debug(SystemDebug.actions,'perform_action',container.last_error)
    return false
  end
  
  
end

def list_params(params)
  return '' if params.nil?
  r = ' '
   params.each do |param|
     r += param.to_s + ' '
   end
end

end