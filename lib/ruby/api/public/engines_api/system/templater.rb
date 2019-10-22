module PublicApiSystemTemplater
  require '/opt/engines/lib/ruby/templater/templater.rb'

  def get_resolved_string(env_value)
    templater = Templater.new(core.system_value_access,nil)
    env_value = templater.apply_system_variables(env_value)
    env_value
  end

end
