module ApiActionators
  @@action_timeout = 20

  def perform_action(c,actionator_name, params, data=nil)
    if params.nil? || params.is_a?(String)
      args = params
    else 
        args = '\'' + params.to_json + '\''        
    end    
    cmd = 'docker exec  ' +  c.container_name + ' /home/actionators/' + actionator_name + '.sh ' + args.to_s
      result = {}
      begin
        Timeout.timeout(@@action_timeout) do
          thr = Thread.new do
            begin
            if data.nil?
            result = SystemUtils.execute_command(cmd)
            else
              STDERR.puts("DATA " + cmd.to_s)
              cmd = ' echo ' + data.to_s + ' > /tmp/.t ; cat /tmp/.t | ' + cmd + ' ; rm /tmp/.t'
              result = SystemUtils.execute_command(cmd)
            #  result = SystemUtils.execute_command(cmd, false, data)
            end 
       
          rescue StandardError =>e
               p :params
               p params
               p :data
               p data
                log_exception(e)
          end
            end
                   thr.join
        end
      rescue Timeout::Error
        return  log_error_mesg('Timeout on Running Action ', cmd)
       
      end
  
      if result[:result] == 0
        if result[:stdout].start_with?('{') || result[:stdout].start_with?('"{') 
          begin
          return JSON.parse( result[:stdout], :create_additons => true )
        rescue
          return result[:stdout]
          end
        end
        return result[:stdout]
      end
    return  log_error_mesg('Error on performing action ' + c.container_name.to_s + ':' + actionator_name.to_s + result[:stderr] ,result)
    rescue StandardError =>e
      p :params
      p params
      p :data
      p data
       log_exception(e)
  
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