#!/home/engines/.rbenv/versions/2.1.3/bin/ruby
require "/opt/engines/lib/ruby/ManagedContainer.rb"
require "/opt/engines/lib/ruby/SysConfig.rb"
require "/opt/engines/lib/ruby/ManagedEngine.rb"
require "/opt/engines/lib/ruby/EnginesOSapi.rb"
require "/opt/engines/lib/ruby/EnginesOSapiResult.rb"

def print_usage
  puts("Usage engines.rb service|engine command engine_name|service_name")
  puts("Where command is one of list|system|network|memory|check_and_act|running|stopped|stop|start|pause|unpause|restart|rebuild|logs|ps|create|recreate|registersite|deregistersite|registerdns|deregisterdns|monitor|demonitor|stats|status|lasterror|databases|volumes|backups|backup_vol|backup_db|stop_backup|destroy|deleteimage|register_consumers")
end

def format_databases(volumes)
  res = String.new
  volumes.keys.each do |key|
    res = res + key +"\n"
  end
  return res
end



def format_backups(volumes)
  res = String.new
  volumes.keys.each do |key|
    res = res + key +"\n"
  end
  return res
end

def format_volumes(volumes)
  res = String.new
  volumes.keys.each do |key|
    res = res + key +"\n"
  end
  return res
end

def do_cmd(c_type,containerName,command)
  engines_api = EnginesOSapi.new()
  core_api = engines_api.core_api

  #  puts "Command" + command + " on " + containerName
  case command
  when "services"
    hash_values =  containerName.split(".")
    if hash_values.count < 1
      p "Incorrect Arguments for services engines services provide.service_type{.name} .name is optional"
      exit
    end 
    params = Hash.new()
    
    params[:publisher_namespace] = hash_values[0]
  if hash_values.count >1 
    params[:service_type] = hash_values[1]
end
    if hash_values.count > 2
      params[:name]= hash_values[2]
    end
    p "looking_for"
    p params
    services = core_api.find_service(params)
    if services == false
      p "Service " + containerName + " not found"
      exit
    end
    services.each do |service|
      p service.name
      p service.content
    end
      
  when "list"
    engines = engines_api.list_managed_engines
    engines.each do |engine_name|
      p engine_name
    end

  when "system"
    mem_hash = engines_api.get_system_memory_info
    load_hash = engines_api.get_system_load_info

    p "Free:" + mem_hash[:free] + "/" + mem_hash[:total] + " Active/Inactive " + mem_hash[:active] + "/" + mem_hash[:inactive]
    p " Buffers/Cache " + mem_hash[:buffers] + "/" + mem_hash[:file_cache]
    p " Swap Free/Total " + mem_hash[:swap_free] + "/" + mem_hash[:swap_total]

    p "Average Processes waiting 1Min/5Min/15Min " + load_hash[:one]  + "/" + load_hash[:five]  + "/" + load_hash[:fithteen]
    p "Processes running/idle " + load_hash[:running]  + "/" + load_hash[:idle]

    return

  when "network"
    net_use_hash = engines_api.get_container_network_metrics(containerName)
    res = "In:" + net_use_hash[:in].to_s + "Bytes Out:" + net_use_hash[:out].to_s + "Bytes"
    puts res

  when "memory"
    if c_type == "container"
      mem_use_hash = engines_api.get_engine_memory_statistics(containerName)
    else
      mem_use_hash = engines_api.get_service_memory_statistics(containerName)
    end

    if mem_use_hash  != nil && !mem_use_hash.instance_of?(EnginesOSapiResult)
      current = mem_use_hash[:current].to_f
      maximum = mem_use_hash[:maximum].to_f
      limit = mem_use_hash[:limit].to_f

      if current.nan? == false && maximum.nan? == false && limit.nan? == false
        current = current / (1024 * 1024)
        maximum = maximum / (1024 * 1024)
        limit = limit / (1024 * 1024)
        max_p = maximum / limit * 100
        curr_p =  current / limit * 100

        current = current.round(0)
        maximum = maximum.round(0)
        limit = limit.round(0)

        if !max_p.nan?
          max_p = max_p.round(0)
        else
          max_p =0
        end
        if !curr_p.nan?
          curr_p = curr_p.round(0)
        else
          curr_p = 0
        end

        res =containerName + ": Current: " + current.to_s + "MB / " + curr_p.to_s + "% Maximum: " + maximum.to_s + "MB / " + max_p.to_s + "% Limit: " + limit.to_s  + "MB\n"

        print res
      end
    end

  when "check_and_act"
    if c_type == "container"
      eng = engines_api.loadManagedEngine(containerName)
    else
      eng = EnginesOSapi.loadManagedService(containerName,core_api)
    end
    state = engines_api.read_state(eng)
    if eng.setState != state
      res = "Error:" + containerName + ":" + state + ":set to:" + eng.setState
      case eng.setState
      when "running"
        res = "Error:starting " + containerName + " was in " + state
        if state == "nocontainer"
          do_cmd(c_type,containerName,"create")
        elsif state == "paused"
          do_cmd(c_type,containerName,"unpause")
        else
          do_cmd(c_type,containerName,"start")
        end
      when "stopped"
        res = "Error:stopping " + containerName + " was in " + state
        do_cmd(c_type,containerName,"stop")
      end
    end

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

  when "rebuild"
    if c_type == "container"
      res = engines_api.rebuild_engine_container(containerName)
    else
      puts "Cannot rebuild Service"
    end

  when "logs"
    if c_type == "container"
      eng = engines_api.loadManagedEngine(containerName)
    else
      eng = EnginesOSapi.loadManagedService(containerName,core_api)
    end
    res =  containerName + ":" + engines_api.logs_container

  when "ps"
    if c_type == "container"
      eng = engines_api.loadManagedEngine(containerName)
    else
      eng = EnginesOSapi.loadManagedService(containerName,core_api)
    end
    res =  containerName + ":" + engines_api.ps_container
  when "destroy"
    if c_type == "container"
      res = engines_api.destroyEngine(containerName)
    else
      puts("Error cannot destroy Service")
    end
  when "deleteimage"
    if c_type == "container"
      res = engines_api.deleteEngineImage(containerName)
    else
      puts("Error cannot delete a Service Image")
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
      puts("Error Monitor Service not applicable")
    end
  when  "demonitor"
    if c_type == "container"
      res = engines_api.demonitorEngine(containerName)
    else
      puts("Error Monitor Service not applicable")
    end
  when  "stats"
    if c_type == "container"
      eng = engines_api.loadManagedEngine(containerName)
    else
      eng = EnginesOSapi.loadManagedService(containerName,core_api)
    end
    if eng.is_a?(EnginesOSapiResult) == false
      res = eng.stats
      if res != nil && res != false
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
      eng = EnginesOSapi.loadManagedService(containerName,core_api)
    end
    if eng.instance_of?(EnginesOSapiResult)
      res = "Error: No such Container:" + containerName
    else

      state = engines_api.read_state(eng)
      if eng.setState != state
        res = "Error:" + containerName + ":" + state + ":set to:" + eng.setState
      else
        res =  containerName + ":" + state
      end
    end
    puts res

  when  "lasterror"
    if c_type == "container"
      eng = engines_api.loadManagedEngine(containerName)
    else
      eng = EnginesOSapi.loadManagedService(containerName,core_api)
    end

    res =  eng.last_error

  when "databases"
    databases = engines_api.get_databases
    res = format_databases databases

  when "volumes"
    volumes = engines_api.get_volumes
    res = format_volumes volumes
  when "backups"
    backups = engines_api.get_backups
    res = format_backups backups

  when "backup_vol"
    #backupname engine_name volumename proto host folder user pass
    args=containerName.split(":")
    backup_name=args[0]
    engine_name=args[1]
    volume_name=args[2]
    dest_hash = Hash.new
    dest_hash[:dest_proto]=args[3]
    dest_hash[:dest_address]=args[4]
    dest_hash[:dest_folder]=args[5]
    dest_hash[:dest_user]=args[6]
    dest_hash[:dest_pass]=args[7]
    p dest_hash
    res = engines_api.backup_volume(backup_name,engine_name,volume_name,dest_hash)
  when "backup_db"
    args=containerName.split(":")
    backup_name=args[0]
    engine_name=args[1]
    database_name=args[2]
    dest_hash = Hash.new
    dest_hash[:dest_proto]=args[3]
    dest_hash[:dest_address]=args[4]
    dest_hash[:dest_folder]=args[5]
    dest_hash[:dest_user]=args[6]
    dest_hash[:dest_pass]=args[7]
    p dest_hash
    res = engines_api.backup_database(backup_name,engine_name,database_name,dest_hash)

  when "stop_backup"
    backup_name= containerName
    res = engines_api.stop_backup(backup_name)
  when "register_consumers"
    eng = EnginesOSapi.loadManagedService(containerName,core_api)
    eng.reregister_consumers

  else
    res =  "command:" + command + " unknown"
    print_usage

  end

  if res !=nil && res.is_a?(EnginesOSapiResult)
    if res.was_success == false
      output = "Failed:" + res.result_mesg.to_s
    else
      output = res.result_mesg
    end

    if output.length >0
      puts output
    end

  end
end

containerName =""
c_type= ARGV[0]
if c_type== "engine"
  c_type = "container"
elsif c_type == "engines"
  c_type = "container"
  containerName = "all"
elsif  c_type == "services"
  c_type = "service"
  containerName = "all"
elsif  c_type == "service"
  c_type = "service"
else
  puts("unknown container type: Please use engine or service")
  print_usage
  exit
end

if ARGV.length != 3 && containerName != "all" || ARGV.length < 2 && containerName == "all"
  print_usage
  exit
end

command = ARGV[1]

if containerName != "all" #backward for scripts that use all instead of plural
  containerName = ARGV[2]
end

if command == 'list'
  do_cmd(c_type,"none",command)
  return
end

if containerName == "all"
  engines_api = EnginesOSapi.new()
  if command == 'list'
    do_cmd(c_type,"none",command)
  elsif c_type == "container"
    engines = engines_api.getManagedEngines()
    engines.each do |engine|
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

