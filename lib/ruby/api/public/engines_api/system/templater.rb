module PublicApiSystemTemplater
  require '/opt/engines/lib/ruby/templater/templater.rb'
  def get_resolved_string(env_value)
 
     templater = Templater.new(@core_api.system_value_access,nil)
     env_value = templater.apply_system_variables(env_value)
      env_value
   rescue StandardError => e
 
     log_exception(e)
   end
   
end