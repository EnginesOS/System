module ApiActionators
  @@action_timeout = 20

  def perform_action(c,actionator_name, params, data=nil)
    if params.nil? || params.is_a?(String)
      args = params
    else 
        args = '\'' + params.to_json + '\''        
    end    
    inter=''
    inter='-i ' unless data.nil?

    cmds = ['/home/actionators/' + actionator_name + '.sh',args.to_s]
      result = {}
      begin
        Timeout.timeout(@@action_timeout) do
          thr = Thread.new do
            begin
            if data.nil?
              result = engines_core.exec_in_container(c, cmds, true)
        #      result = SystemUtils.execute_command(cmd)
            else
              result = engines_core.exec_in_container(c, cmds, true, data)
              # result = SystemUtils.execute_command(cmd, false, data)
            end 
       
          rescue StandardError =>e

                log_exception(e)
          end
            end
                   thr.join
        end
      rescue Timeout::Error
        return  log_error_mesg('Timeout on Running Action ', cmds.to_s)
       
      end
       return result if result.is_a?(EnginesError)
       
      if result[:result] == 0
        if result[:stdout].start_with?('{') || result[:stdout].start_with?('"{') 
          begin
          return JSON.parse( result[:stdout], :create_additons => true , :symbolize_keys => true)
        rescue         
          return result[:stdout]
          end
        end
        STDERR.puts '____' + result[:stdout].to_s + '____________'
                 return true if result[:stdout].start_with?('true') || result[:stdout].start_with?('"true') 
        return result[:stdout]
      end
    return  log_error_mesg('Error on performing action ' + c.container_name.to_s + ':' + actionator_name.to_s + result[:stderr] ,result)
    rescue StandardError =>e
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