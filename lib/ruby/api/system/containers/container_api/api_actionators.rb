module ApiActionators
  @@action_timeout = 20
  


  def perform_action(c,actionator_name, args, data=nil)
      # cmd = 'docker exec -u ' + c.cont_userid + ' ' +  c.container_name + ' /home/configurators/read_' + params[:configurator_name].to_s + '.sh '
      cmd = 'docker exec  ' +  c.container_name + ' /home/actionators/' + actionator_name + '.sh \'' + args.to_json + '\''
      result = {}
      begin
        Timeout.timeout(@@action_timeout) do
          thr = Thread.new do
            if data.nil?
            result = SystemUtils.execute_command(cmd)
            else
              result = SystemUtils.execute_command(cmd, false, data)
            end 
          end
          thr.join
        end
      rescue Timeout::Error
        return  log_error_mesg('Timeout on Running Action ', cmd)
       
      end
  
      if result[:result] == 0
        #variables = SystemUtils.hash_string_to_hash(result[:stdout])
#        variables_hash = JSON.parse( result[:stdout], :create_additons => true )
#        params[:variables] = SystemUtils.symbolize_keys(variables_hash)      
        return result[:stdout]
      end
    return  log_error_mesg('Error on performing action ' + c.container_name.to_s + ':' + actionator_name.to_s + result[:stderr] ,result)
   
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