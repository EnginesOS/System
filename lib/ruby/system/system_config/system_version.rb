module SystemVersion
  @@api_version = '0.1'
  @@engines_system_version = '0.1'

  
 def SystemConfig.api_version
return @@api_version
end

def SystemConfig.engines_system_version
return @@engines_system_version
end

end