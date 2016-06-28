#!/usr/local/rvm/rubies/ruby-2.1.1/bin/ruby
require "/opt/engines/lib/ruby/ManagedContainer.rb"
require "/opt/engines/lib/ruby/SysConfig.rb"
require "/opt/engines/lib/ruby/ManagedEngine.rb"


def do_cmd (mca,cmd)

case cmd
  when "stop" 
   res = mca.stop_container
  when  "start"
   res = mca.start_container
  when "pause"
   res = mca.pause_container
  when  "unpause"
   res = mca.unpause_container
  when "restart"
   res = mca.restart_container
  when "logs"
  res = mca.logs_container
  when "ps"
  res = mca.ps_container
  when "destroy"
  res = mca.destroy_container
  when "deleteimage"
  res = mca.delete_image
  when  "create"
  res = mca.create_container
  when  "recreate"
  res = mca.recreate_container
  when  "registersite"
  res = mca.register_site
  when  "deregistersite"
  res = mca.deregister_site
  when  "monitor"
  res = mca.monitor_site
  when  "demonitor"
  res = mca.demonitor_site 
  when  "stats"
      res = mca.stats
              if res != nil
                if res.state == "stopped"
                  puts "State:" + res.state + res.proc_cnt.to_s + " Procs " + "Stopped:" + res.stopped_ts + "Memory:V:" + res.RSSMemory.to_s + " R:" + res.VSSMemory.to_s +   " cpu:" + res.cpuTime.to_s 
                else
                  puts "State:" + res.state + res.proc_cnt.to_s + " Procs " + "Started:" + res.started_ts + "Memory:V:" + res.RSSMemory.to_s + " R:" + res.VSSMemory.to_s +  " cpu:" + res.cpuTime.to_s
                end                 
              end       
  when  "status"
      res = mca.status 
        puts mca.containerName + ":" + res
          
  when  "lasterror"
    puts mca.slast_error
  else
    puts "command:" + cmd + " unknown" 
    
 end
 
   if(res == false)
      puts "Error" + mca.slast_error
    end
    
end


type= ARGV[0]
if type== "engine"
  type = "container"
end

cm = ARGV[1]
cmd = ARGV[2]



#CidDir="/opt/engines/run"

  if cm == "all"
    if type == "container"
    
    mcas=ManagedEngine.getManagedEngine(type)
      mcas.each do |mca|
        puts(mca.containerName + ":")
        do_cmd(mca,cmd)
      end
    end
  else
    cfn=SysConfig.CidDir + "/"  + type + "s/" + cm + "/config.yaml"

      if File.file?(cfn)
        cf = File.open(cfn)
      else
        puts "Error:no config found for" + cm 
        exit     
      end
 
 

  
mca = ManagedEngine.from_yaml( cf ) 
cf.close
  do_cmd(mca,cmd)
end





