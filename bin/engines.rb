#!/home/engines/.rbenv/shims/ruby
require 'yaml'
require "/opt/engines/lib/ruby/containers/managed_container.rb"
require "/opt/engines/lib/ruby/system/system_config.rb"
require "/opt/engines/lib/ruby/containers/managed_engine.rb"
require "/opt/engines/lib/ruby/containers/managed_service.rb"
require "/opt/engines/lib/ruby/containers/system_service.rb"
require "/opt/engines/lib/ruby/containers/container.rb"
require "/opt/engines/lib/ruby/api/public/engines_osapi.rb"
require "/opt/engines/lib/ruby/api/public/engines_osapi_result.rb"


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

def do_cmd(c_type,container_name,command)
  engines_api = EnginesOSapi.new()
  core_api = engines_api.core_api

  #  puts "Command" + command + " on " + container_name
  case command
    
  when "clean"
    core_api.clean_up_dangling_images 
    
  when "providers"

      engines_api = EnginesOSapi.new()
      core_api = engines_api.core_api
      
     providers = core_api.list_providers_in_use

     providers.each do |provider|
              p   provider
              end
       
    
  when "services"
    ## latter this will allow addressing engine.type_path
    hash_values =  container_name.split(".")
        if hash_values.count < 1
          p "Incorrect Arguments for services engine services engine.provide.service_type all after engine is optional"
          exit
        end 
        params = Hash.new()
    if hash_values.count >1
        params[:type_path] = hash_values[1]
  end     
 
#        p "looking_for"
#        p params
  if hash_values.count >2
         params[:service_handle] = hash_values[2]
     end 
    params[:parent_engine]=hash_values[0]
      
        services = core_api.find_engine_services(params)
        if services == false
          p "Service " + container_name + " not found"
          exit
        end
        if services == nil
          p "No Match from params " + params.to_s
        else
        
          services.each do |service|
            p "Name:" + service.name.to_s
            p "Content:" + service.content.to_s
          end
        end

when "persistant_services"
  params = Hash.new()
  params[:engine_name] =   container_name
    result = engines_api.get_engine_persistant_services(params)
    p result.to_s

#remove the service matching the service_hash from the tree
 #@service_hash :publisher_namespace :type_path :service_handle
 #def remove_from_services_registry(service_hash)
    
when "rm_service"
   hash_values =  container_name.split(".")
   if hash_values.count < 3
     p "Incorrect Arguments for rm service engines services provide.service_type{.name} .name is optional"
     exit
   end 
   params = Hash.new()
   
   params[:publisher_namespace] = hash_values[0]

   params[:type_path] = hash_values[1]
     
    if hash_values.count > 2
      params[:parent_engine]= hash_values[2]
    end
     
     if hash_values.count > 3
      params[:service_handle]= hash_values[3]
     end

   services = core_api.delete_service_from_service_registry(params)
   if services == false
     p "Service " + container_name + " not found"
     exit
   end

  when "rm_service_from_engine"
hash_values =  container_name.split(".")
if hash_values.count < 2
  p "Incorrect Arguments for rm service from engine engine.service_type{.name} .name is optional"
  exit
end 
params = Hash.new()

params[:parent_engine] = hash_values[0]

params[:type_path] = hash_values[1]
   
  if hash_values.count > 2
   params[:service_handle]= hash_values[2]
  end

services = core_api.delete_service_from_engine_registry(params)
if services == false
  p "Service " + container_name + " not found"
  exit
end
     

  when "list_services"
    hash_values =  container_name.split(".")
    if hash_values.count < 1
      p "Incorrect Arguments for services engines services provide.service_type{.name} .name is optional"
      exit
    end 
    params = Hash.new()
    
    params[:publisher_namespace] = hash_values[0]
  if hash_values.count >1 
    params[:type_path] = hash_values[1]
end
    if hash_values.count > 2
      params[:parent_engine]= hash_values[2]
    end
if hash_values.count > 3
   params[:service_handle]= hash_values[3]
 end
    p "looking_for"
    p params
    services = core_api.find_service_consumers(params)
    if services == false
      p "Service " + container_name + " not found"
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
    net_use_hash = engines_api.get_container_network_metrics(container_name)
    res = "In:" + net_use_hash[:in].to_s + "Bytes Out:" + net_use_hash[:out].to_s + "Bytes"
    puts res

  when "memory"
    if c_type == "container"
      mem_use_hash = engines_api.get_engine_memory_statistics(container_name)
    else
      mem_use_hash = engines_api.get_service_memory_statistics(container_name)
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

        res =container_name + ": Current: " + current.to_s + "MB / " + curr_p.to_s + "% Maximum: " + maximum.to_s + "MB / " + max_p.to_s + "% Limit: " + limit.to_s  + "MB\n"

        print res
      end
    end

when "reinstall"
if c_type != "container"
  res = "Error: Reinstall not applicable to " +  c_type
else
  engines_api.reinstall_engine(container_name)
end
  when "check_and_act"
    if c_type == "container"
      eng = engines_api.loadManagedEngine(container_name)
    else
      eng = EnginesOSapi.loadManagedService(container_name,core_api)
    end
    state = engines_api.read_state(eng)
    if eng.setState != state
      res = "Error:" + container_name + ":" + state + ":set to:" + eng.setState
      case eng.setState
      when "running"
        res = "Error:starting " + container_name + " was in " + state
        if state == "nocontainer"
          do_cmd(c_type,container_name,"create")
        elsif state == "paused"
          do_cmd(c_type,container_name,"unpause")
        else
          do_cmd(c_type,container_name,"start")
        end
      when "stopped"
        res = "Error:stopping " + container_name + " was in " + state
        do_cmd(c_type,container_name,"stop")
      end
    end

  when "stop"
    if c_type == "container"
      res = engines_api.stopEngine(container_name)
    else
      res = engines_api.stopService(container_name)
    end
  when  "start"
    if c_type == "container"
      res = engines_api.startEngine(container_name)
    else
      res = engines_api.startService(container_name)
    end
  when "pause"
    if c_type == "container"
      res = engines_api.pauseEngine(container_name)
    else
      res = engines_api.pauseService(container_name)
    end
  when  "unpause"
    if c_type == "container"
      res = engines_api.unpauseEngine(container_name)
    else
      res = engines_api.unpauseService(container_name)
    end
  when "restart"
    if c_type == "container"
      res = engines_api.restartEngine(container_name)
    else
      res = engines_api.restartService(container_name)
    end

  when "rebuild"
    if c_type == "container"
      res = engines_api.rebuild_engine_container(container_name)
    else
      puts "Cannot rebuild Service"
    end

  when "logs"
    if c_type == "container"
      eng = engines_api.loadManagedEngine(container_name)
    else
      eng = EnginesOSapi.loadManagedService(container_name,core_api)
    end
    res =  container_name + ":" + engines_api.logs_container

  when "ps"
    if c_type == "container"
      eng = engines_api.loadManagedEngine(container_name)
    else
      eng = EnginesOSapi.loadManagedService(container_name,core_api)
    end
    res =  container_name + ":" + engines_api.ps_container
  when "destroy"
    if c_type == "container"
      res = engines_api.destroyEngine(container_name)
    else
      puts("Error cannot destroy Service")
    end
  when "deleteimage"
    if c_type == "container"
      params = Hash.new
      params[:engine_name]= container_name
      res = engines_api.deleteEngineImage(params)
    else
      puts("Error cannot delete a Service Image")
    end
    when "DeleteImage"
if c_type == "container"
     params = Hash.new
  params[:engine_name]= container_name
    params[:remove_all_application_data] = true
     res = engines_api.deleteEngineImage(params)
   else
     puts("Error cannot delete a Service Image")
   end
    when "delete_services"
    if c_type != "container"
      puts "Error cannot delete services from " +  c_type
      exit
    end
      eng = engines_api.loadManagedEngine(container_name)
      if eng.is_a?(EnginesOSapiResult) == false
        p "Error cannot delete Services from an active Image"
        exit
      end
      params = Hash.new
      params[:engine_name] = container_name
      params[:remove_all_application_data] = true
      engines_api.delete_image_dependancies(params)    
    
  when  "create"
    if c_type == "container"
      res = engines_api.createEngine(container_name)
    else
      res = engines_api.createService(container_name)
    end
  when  "recreate"
    if c_type == "container"
      res = engines_api.recreateEngine(container_name)
    else
      res = engines_api.recreateService(container_name)
    end
  when  "registersite"
    if c_type == "container"
      res = engines_api.registerEngineWebSite(container_name)
    else
      res = engines_api.registerServiceWebSite(container_name)
    end
  when  "deregistersite"
    if c_type == "container"
      res = engines_api.deregisterEngineWebSite(container_name)
    else
      res = engines_api.deregisterServiceWebSite(container_name)
    end
  when  "registerdns"
    if c_type == "container"
      res = engines_api.registerEngineDNS(container_name)
    else
      res = engines_api.registerServiceDNS(container_name)
    end
  when  "deregisterdns"
    if c_type == "container"
      res = engines_api.deregisterEngineDNS(container_name)
    else
      res = engines_api.deregisterServiceDNS(container_name)
    end
  when  "monitor"
    if c_type == "container"
      res = engines_api.monitorEngine(container_name)
    else
      puts("Error Monitor Service not applicable")
    end
  when  "demonitor"
    if c_type == "container"
      res = engines_api.demonitorEngine(container_name)
    else
      puts("Error Monitor Service not applicable")
    end
  when  "stats"
    if c_type == "container"
      eng = engines_api.loadManagedEngine(container_name)
    else
      eng = EnginesOSapi.loadManagedService(container_name,core_api)
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
      eng = engines_api.loadManagedEngine(container_name)
    else
      eng = EnginesOSapi.loadManagedService(container_name,core_api)
    end
    if eng.instance_of?(EnginesOSapiResult)
      res = "Error: No such Container:" + container_name
    else

      state = engines_api.read_state(eng)
      if eng.setState != state
        res = "Error:" + container_name + ":" + state + ":set to:" + eng.setState
      else
        res =  container_name + ":" + state
      end
    end
    puts res

  when  "lasterror"
    if c_type == "container"
      eng = engines_api.loadManagedEngine(container_name)
    else
      eng = EnginesOSapi.loadManagedService(container_name,core_api)
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
    args=container_name.split(":")
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
    args=container_name.split(":")
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
    backup_name= container_name
    res = engines_api.stop_backup(backup_name)
  when "register_consumers"
    eng = EnginesOSapi.loadManagedService(container_name,core_api)
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

if Process.euid != 21000
  p "This program can only be run be the engines user"
  exit
end

container_name =""
c_type= ARGV[0]
if c_type== "engine"
  c_type = "container"
elsif c_type == "engines"
  c_type = "container"
  container_name = "all"
elsif  c_type == "services"
  c_type = "service"
  container_name = "all"
elsif  c_type == "service"
  c_type = "service"
else
  puts("unknown container type: Please use engine or service")
  print_usage
  exit
end

if ARGV.length != 3 && container_name != "all" || ARGV.length < 2 && container_name == "all"
  print_usage
  exit
end

command = ARGV[1]

if container_name != "all" #backward for scripts that use all instead of plural
  container_name = ARGV[2]
end

if command == 'list'
  do_cmd(c_type,"none",command)
  return
end

if container_name == "all"
  engines_api = EnginesOSapi.new()
  if command == 'list'
    do_cmd(c_type,"none",command)
  elsif c_type == "container"
    engines = engines_api.getManagedEngines()
    engines.each do |engine|
      do_cmd(c_type,engine.container_name,command)
    end
  elsif c_type == "service"
    services = engines_api.getManagedServices()
    services.each do |service|
      do_cmd(c_type,service.container_name,command)
    end
  end
else
  do_cmd(c_type,container_name,command)
end

