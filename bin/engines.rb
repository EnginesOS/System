#!/usr/local/rvm/rubies/ruby-2.1.1/bin/ruby
require "/opt/engos/lib/ruby/ManagedContainer.rb"
require "/opt/engos/lib/ruby/SysConfig.rb"
require "/opt/engos/lib/ruby/ManagedEngine.rb"
require "/opt/engos/lib/ruby/EnginesOSapi.rb"
require "/opt/engos/lib/ruby/EnginesOSapiResult.rb"

def do_cmd(c_type,containerName,command)
  engines_api = EnginesOSapi.new() 
  case command
    when "stop" 
      if c_type == "container"
       res = engines_api.stopEngine(containerName)
      else
        res = engines_api.stopService(containerName)
      end
    when  "start"
    if c_type == "container"
      res = engines_api.startEngine(containerName)
    else
      res = engines_api.startService(containerName)
    end
    when "pause"
    if c_type == "container"
      res = engines_api.pauseEngine(containerName)
    else
      res = engines_api.pauseService(containerName)
    end
    when  "unpause"
    if c_type == "container"
      res = engines_api.unpauseEngine(containerName)
    else
      res = engines_api.unpauseService(containerName)
    end
    when "restart"
    if c_type == "container"
      res = engines_api.restartEngine(containerName)
    else
      res = engines_api.restartService(containerName)
    end
  
    when "logs"
    if c_type == "container"
         eng = engines_api.loadManagedEngine(containerName)
       else
         eng = EnginesOSapi.LoadMangedService(containerName,engines_api)
       end
       res =  containerName + ":" + engines_api.logs_container

   when "ps"
    if c_type == "container"
         eng = engines_api.loadManagedEngine(containerName)
       else
         eng = EnginesOSapi.LoadMangedService(containerName,engines_api)
       end
       res =  containerName + ":" + engines_api.ps_container
    when "destroy"
    if c_type == "container"
      res = engines_api.destroyEngine(containerName)
    else
      puts ("Error cannot destroy Service")
    end
    when "deleteimage"
    if c_type == "container"
      res = engines_api.delete_image(containerName)
    else
      puts ("Error cannot delete a Service Image")
    end
    when  "create"
    if c_type == "container"
      res = engines_api.createEngine(containerName)
    else
      res = engines_api.createService(containerName)
    end
    when  "recreate"
    if c_type == "container"
      res = engines_api.recreateEngine(containerName)
    else
      res = engines_api.recreateService(containerName)
    end
    when  "registersite"
    if c_type == "container"
      res = engines_api.registerEngineWebSite(containerName)
    else
      res = engines_api.registerServiceWebSite(containerName)
    end
    when  "deregistersite"
    if c_type == "container"
      res = engines_api.deregisterEngineWebSite(containerName)
    else
      res = engines_api.deregisterServiceWebSite(containerName)
    end
    when  "registerdns"
       if c_type == "container"
         res = engines_api.registerEngineDNS(containerName)
       else
         res = engines_api.registerServiceDNS(containerName)
       end
       when  "deregisterdns"
       if c_type == "container"
         res = engines_api.deregisterEngineDNS(containerName)
       else
         res = engines_api.deregisterServiceDNS(containerName)
       end
    when  "monitor"
    if c_type == "container"
      res = engines_api.monitorEngine(containerName)
    else
      puts ("Error Monitor Service not applicable")
    end
    when  "demonitor"
    if c_type == "container"
      res = engines_api.demonitorEngine(containerName)
    else
      puts ("Error Monitor Service not applicable")
    end 
    when  "stats"
    if c_type == "container"
      eng = engines_api.loadManagedEngine(containerName)
    else
      eng = EnginesOSapi.LoadMangedService(containerName,engines_api)
    end
    if eng.is_a?(EnginesOSapiResult) == false
        res = eng.stats
                if res != nil
                  if res.state == "stopped"
                    res = "State:" + res.state + res.proc_cnt.to_s + " Procs " + "Stopped:" + res.stopped_ts + "Memory:V:" + res.RSSMemory.to_s + " R:" + res.VSSMemory.to_s +   " cpu:" + res.cpuTime.to_s 
                  else
                    res = "State:" + res.state + res.proc_cnt.to_s + " Procs " + "Started:" + res.started_ts + "Memory:V:" + res.RSSMemory.to_s + " R:" + res.VSSMemory.to_s +  " cpu:" + res.cpuTime.to_s
                  end                 
                end
    else        
         res = eng
    end
                       
    when  "status"
    if c_type == "container"
      eng = engines_api.loadManagedEngine(containerName)
    else
      eng = EnginesOSapi.LoadManagedService(containerName,engines_api)
    end
    res =  containerName + ":" +engines_api.read_state(eng)
            
    when  "lasterror"
    if c_type == "container"
      eng = engines_api.loadManagedEngine(containerName)
    else
      eng = EnginesOSapi.LoadMangedService(containerName,engines_api)
    end
  
    res =  eng.last_error
    
    else
      res =  "command:" + cmd + " unknown" 
      
   end
 
     if res !=nil && res.is_a?(EnginesOSapiResult)    
       if res.was_sucess == false
         puts ("Failed:" + res.result_mesg)
       else
         puts(res.result_mesg)
     end
     else
       p res
     end
end

c_type= ARGV[0]
if c_type== "engine"
  c_type = "container"
end

command = ARGV[1]
containerName = ARGV[2]
  if containerName == "all"
    engines_api = EnginesOSapi.new() 
    if c_type == "container"
      engines = engines_api.getManagedEngines()
      engines.each do |engine|     
        puts engine.containerName
        do_cmd(c_type,engine.containerName,command)
      end
    elsif c_type == "service"
      services = engines_api.getManagedServices()
      services.each do |service|
        do_cmd(c_type,service.containerName,command)
       end
    end
  else
    do_cmd(c_type,containerName,command)
  end


