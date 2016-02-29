module ApiActionators
 def perform_action(constainer, actionator_name, params)
  cmd ='docker exec /home/actionators/' + actionator_name + ' ' +list_params(params)
  if @docker_api.execute_docker_cmd(cmdline, constainer)
   return container.last_result
  else
    @last_error  = container.last_error 
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