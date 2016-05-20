module ApiActionators
  @@action_timeout = 20
  


  def perform_action(c,actionator_name, params)
      # cmd = 'docker exec -u ' + c.cont_userid + ' ' +  c.container_name + ' /home/configurators/read_' + params[:configurator_name].to_s + '.sh '
      cmd = 'docker exec  ' +  c.container_name + ' /home/actionators/' + actionator_name + '.sh \'' + params.to_json + '\''
      result = {}
      begin
        Timeout.timeout(@@action_timeout) do
          thr = Thread.new { result = SystemUtils.execute_command(cmd) }
          thr.join
        end
      rescue Timeout::Error
        return  log_error_mesg('Timeout on Running Action ',cmd)
       
      end
  
      if result[:result] == 0
        #variables = SystemUtils.hash_string_to_hash(result[:stdout])
#        variables_hash = JSON.parse( result[:stdout], :create_additons => true )
#        params[:variables] = SystemUtils.symbolize_keys(variables_hash)      
        return result[:stdout]
      end
    return  log_error_mesg('Error on retrieving Configuration ' + result[:stderr] ,result)
   
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