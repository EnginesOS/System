

require_relative "SoftwareService.rb"
class CronService < SoftwareService 
  
  def add_consumer_to_service(site_hash)
    site_hash[:variables][:parent_engine] = site_hash[:parent_engine]  
      return  add_cron(site_hash) 
     end
     
  def rm_consumer_from_service (site_hash)
       return  rebuild_crontab()  
  end 
     
  def get_site_hash(site_hash)
    site_hash[:service_type]='cron'
    site_hash[:publisher_namespace] = "EnginesSystem"
        return site_hash          
   end
   
  #noop overloads 
   
    def reregister_consumers
          #No Need they are static
    end
    
  def format_cron_line(cron_hash)
      cron_line = String.new
      cron_line_split = cron_hash[:variables][:cron_job].split(/[\s\t]{1,10}/)
      for n in 0..4
        cron_line +=  cron_line_split[n] + " "
      end
      cron_line +=" docker exec " +  cron_hash[:variables][:parent_engine] + " "
      n=5
      cnt = cron_line_split.count

      while n < cnt
        cron_line += " " + cron_line_split[n]
        n+=1
      end
      return     cron_line
    rescue Exception=>e

SystemUtils.log_exception(e)

      return false
    end

  def remove_containers_cron_list(containerName)
   
    p :remove_cron_for
    p containerName

  consumers.each do |cron_job|
      if cron_job != nil
        p cron_job
        p :looking_at
        p cron_job[1][:variables][:parent_engine]
        if cron_job[1][:variables][:parent_engine] ==  containerName
          remove_consumer(cron_job[1])
        end
      end
    end
  rescue Exception=>e

SystemUtils.log_exception(e)

    return false
  end

  
  def reload_crontab
    docker_cmd="docker exec cron /home/cron/bin/fcrontab -z " #+ "/home/crontabs/crontab"
     SystemUtils.run_system(docker_cmd)
     return true
  rescue Exception=>e
  
    SystemUtils.log_exception(e)
  
    return false
  end
  
      def rebuild_crontab()
        cron_file = File.open(  SysConfig.CronDir + "/cron.orig","w")
  
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
        cron_file = File.open(  SysConfig.CronDir + "/cron.orig","a+")
        cron_file.puts(cron_line)
        cron_file.close

        return reload_crontab

      rescue Exception=>e

        SystemUtils.log_exception(e)
        return false
      end
    end
    
    

end
