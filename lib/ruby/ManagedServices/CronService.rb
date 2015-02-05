require "/opt/engines/lib/ruby/ManagedContainer.rb"
require_relative  "ManagedService.rb"
class CronService < ManagedService 
  
  def add_consumer_to_service(site_hash)
    site_hash[:container_name] = site_hash[:parent_engine]  
      return  add_cron(site_hash) 
     end
  def rm_consumer_from_service (site_hash)
       return  rebuild_crontab()  
    end 
     
  def get_site_hash(site_hash)
    site_hash[:service_type]='cron'
    site_hash[:service_provider] = "EnginesSystem"
        return site_hash          
   end
   
  #noop overloads 
   
    def reregister_consumers
          #No Need they are static
    end
    

  def remove_containers_cron_list(containerName)
   
    p :remove_cron_for
    p containerName

  consumers.each do |cron_job|
      if cron_job != nil
        p cron_job
        p :looking_at
        p cron_job[1][:container_name]
        if cron_job[1][:container_name] ==  containerName
          remove_consumer(cron_job[1])
        end
      end
    end
  rescue Exception=>e

    log_exception(e)

    return false
  end

  
  def reload_crontab
    docker_cmd="docker exec cron crontab " + "/home/crontabs/crontab"
    return SystemUtils.run_system(docker_cmd)
  rescue Exception=>e
  
    SystemUtils.log_exception(e)
  
    return false
  end
  
      def rebuild_crontab()
        cron_file = File.open(  SysConfig.CronDir + "/crontab","w")
  
        consumers.each do |cron_entry|
  
          cron_line = format_cron_line(cron_entry[1])
          p :cron_line
          p cron_line
          cron_file.puts(cron_line)
        end
        cron_file.close
        return reload_crontab
  
      rescue Exception=>e
  
  SystemUtils.log_exception(e)
  
        return false
  
      end
    
  def add_cron(cron_hash)
      begin

        cron_line = format_cron_line(cron_hash)
        cron_file = File.open(  SysConfig.CronDir + "/crontab","a+")
        cron_file.puts(cron_line)
        cron_file.close

        return reload_crontab

      rescue Exception=>e

        SystemUtils.log_exception(e)
        return false
      end
    end
    
    

end
