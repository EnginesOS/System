module ApiActionators
 def perform_action(actionator_name,params)
  cmd ='/home/actionators/' + actionator_name + ' ' +list_params(params)
  return SystemUtils.execute_command(cmd)
  
end

def list_params(params)
  r = ' '
   params.each do |param|
     r += param.to_s + ' '
   end
end

end