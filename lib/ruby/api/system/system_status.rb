class SystemStatus
  
  def SystemStatus.is_base_system_updating?
     return File.exist?(SystemConfig.SystemUpdatingFlag)
   end
 
   def SystemStatus.is_rebooting?
     File.exist?(SystemConfig.SystemRebootingFlag)
   end  

  def SystemStatus.needs_reboot?
     return File.exist?(SystemConfig.EnginesSystemRebootNeededFlag)
   end
   
  def SystemStatus.engines_system_has_updated?
    if File.exist?(SystemConfig.EnginesSystemUpdatedFlag)
      File.delete(SystemConfig.EnginesSystemUpdatedFlag)
      return true
    end
    return false
  end

  def SystemStatus.is_engines_system_updating?
    return File.exist?(SystemConfig.EnginesSystemUpdatingFlag)
  end

  def SystemStatus.base_system_has_updated?
    if File.exist?(SystemConfig.SystemUpdatedFlag)
      File.delete(SystemConfig.SystemUpdatedFlag)
      return true
    end
    return false
  end

  def SystemStatus.is_building?
    return File.exists?(SystemConfig.BuildRunningParamsFile) 
  end
  
  def SystemStatus.did_build_fail?
    return File.exist?(SystemConfig.BuildFailedFile)
  end
  
  def SystemStatus.did_build_complete?
    return File.exist?(SystemConfig.BuildBuiltFile)
  end
  
def SystemStatus.build_failed(params)
    if File.exist?(SystemConfig.BuildRunningParamsFile)
      File.delete(SystemConfig.BuildRunningParamsFile)
    end
  param_file = File.new(SystemConfig.BuildFailedFile,'w')
  param_file.puts(params.to_yaml)
  param_file.close
end

def SystemStatus.build_complete(params)
  param_file = File.new(SystemConfig.BuildBuiltFile,'w')
   param_file.puts(params.to_yaml)
   param_file.close
  if File.exist?(SystemConfig.BuildRunningParamsFile)
    File.delete(SystemConfig.BuildRunningParamsFile)
  end
end

def SystemStatus.build_starting(params)
  param_file = File.new(SystemConfig.BuildRunningParamsFile,'w')
  param_file.puts(params.to_yaml)
  param_file.close
  if File.exist?(SystemConfig.BuildFailedFile)
    File.delete(SystemConfig.BuildFailedFile)
  end
  if  File.exist?(SystemConfig.BuildBuiltFile)
    File.delete(SystemConfig.BuildBuiltFile)
  end
end

def SystemStatus.build_status
  result = {}
  result[:is_building] = SystemStatus.is_building?
  result[:did_build_fail] = SystemStatus.did_build_fail?
  result[:did_build_complete] = SystemStatus.did_build_complete?
  return result
end

  def SystemStatus.system_status
    result = {}
    result[:is_rebooting] = SystemStatus.is_rebooting?
    result[:is_base_system_updating]=SystemStatus.is_base_system_updating?
    result[:is_engines_system_updating] = SystemStatus.is_engines_system_updating?
    result[:needs_reboot] = SystemStatus.needs_reboot?      
    return result
  end
  
  def SystemStatus.current_build_params     
      param_file = File.new(SystemConfig.BuildRunningParamsFile,'r')
      param_raw = param_file.read
      params = YAML::load(param_raw)    
      return params
    rescue
    return {}      
    end
    
  def SystemStatus.last_build_params    
    param_file = File.new(SystemConfig.BuildBuiltFile)
    param_raw = param_file.read
    params = YAML::load(param_raw)    
    return params
  rescue
    return {}
    
  end
  def SystemStatus.last_build_failure_params    
    param_file = File.new(SystemConfig.BuildFailedFile)
    param_raw = param_file.read
    params = YAML::load(param_raw)    
    return params
  rescue
    return {}
  end
  
  
  def SystemStatus.get_system_memory_info
    ret_val = {}
      proc_mem_info_file = File.open('/proc/meminfo')
      proc_mem_info_file.each_line  do |line|
        values=line.split(' ')
        case values[0]
        when 'MemTotal:'
          ret_val[:total] = values[1]
        when 'MemFree:'
          ret_val[:free] = values[1]
        when 'Buffers:'
          ret_val[:buffers] = values[1]
        when 'Cached:'
          ret_val[:file_cache] = values[1]
        when 'Active:'
          ret_val[:active ] = values[1]
        when 'Inactive:'
          ret_val[:inactive] = values[1]
        when 'SwapTotal:'
          ret_val[:swap_total] = values[1]
        when 'SwapFree:'
          ret_val[:swap_free] = values[1]
        end
      end
      return ret_val
    rescue   Exception=>e
      SystemUtils.log_exception(e)
      ret_val[:total] = e.to_s
      ret_val[:free] = -1
      ret_val[:active] = -1
      ret_val[:inactive] = -1
      ret_val[:file_cache] = -1
      ret_val[:buffers] = -1
      ret_val[:swap_total] = -1
      ret_val[:swap_free] = -1
      return ret_val
  end

  def SystemStatus.get_system_load_info
    ret_val = {}
      loadavg_info = File.read('/proc/loadavg')
      values = loadavg_info.split(' ')
      ret_val[:one] = values[0]
      ret_val[:five] = values[1]
      ret_val[:fithteen] = values[2]
      run_idle = values[3].split('/')
      ret_val[:running] = run_idle[0]
      ret_val[:idle] = run_idle[1]
    rescue Exception=>e
      SystemUtils.log_exception(e)
      ret_val[:one] = -1
      ret_val[:five] = -1
      ret_val[:fithteen] = -1
      ret_val[:running] = -1
      ret_val[:idle] = -1
      return ret_val
    rescue Exception=>e
      SystemUtils.log_exception(e)
      return false
  end
  
  def SystemStatus.is_engines_system_upto_date?()
    result = SystemUtils.execute_command('/opt/engines/bin/engines_system_update_status.sh')
    return result      
  end
end