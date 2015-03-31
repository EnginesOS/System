require_relative "SoftwareService.rb"

class BackupService < SoftwareService
  def add_consumer_to_service(service_hash)
    return  create_backup(service_hash)
  end

  def rm_consumer_from_service (service_hash)
    return  rm_backup(service_hash)
  end

  def create_backup(service_hash)

    begin

      if service_hash.has_key?(:parent_engine)
        containerName = service_hash[:parent_engine]
      else
        containerName = service_hash[:parent_engine]

      end
      # {:parent_engine=>"owncloud", :service_type=>"backup", :publisher_namespace=>"EnginesSystem", :title=>"Backup", :name=>"owncloudapp", :dest_proto=>"ftp", :dest_folder=>"203.14.203.141", :dest_address=>"/tmp/", :include_logs=>"1", :dest_user=>"admin", :dest_pass=>"admin"}

      SystemUtils.debug_output("create backup",service_hash)
      #FIXME
      #kludge
      #
      #      service_hash[:source_user]="testuser"
      #      service_hash[:source_host]="testhostl"
      #      service_hash[:source_pass]="testpass"

      if service_hash.has_key?(:source_type) == false ||  service_hash[:source_type] == "engine"
        service_hash[:source_type] ="engine"
        service_hash[:source_name] = service_hash[:parent_engine]
        if service_hash.has_key?(:include_log) == false ||  service_hash[:include_log] ==nil
          service_hash[:include_log]=false
        end
        site_src   =  service_hash[:parent_engine] + ":system:" + service_hash[:include_log].to_s
      elsif  service_hash[:source_type] =="fs"
        site_src=containerName + ":fs:" + service_hash[:source_name]
      else #database
        site_src=containerName + ":" + service_hash[:source_type] + ":" +  service_hash[:db_username] +":" +  service_hash[:db_password] + "@" +  service_hash[:database_host] + "/" + service_hash[:database_name]
      end
      #FIXME
      site_dest=service_hash[:dest_proto]
      site_dest += ":" + service_hash[:dest_user]
      site_dest += ":" + service_hash[:dest_pass] + "@"
      site_dest +=service_hash[:dest_address] + "/"
      site_dest +=service_hash[:dest_folder]

      SystemUtils.run_system( "docker exec backup /home/add_backup.sh " + service_hash[:name] + " " + site_src + " " + site_dest)
      #    ssh_cmd=SysConfig.addBackupCmd + " " + service_hash[:name] + " " + site_src + " " + site_dest
      #    SystemUtils.run_system(ssh_cmd)
      #FIXME shoudl return about result and not just true
      return true

    rescue  Exception=>e
      SystemUtils.log_exception(e)
      return false
    end
  end

  def rm_backup(service_hash)
    clear_error
    begin
      ssh_cmd=SysConfig.rmBackupCmd + " " + service_hash[:name]
      return SystemUtils.run_system(ssh_cmd)
    rescue  Exception=>e
      SystemUtils.log_exception(e)
      return false
    end
  end

  #  def get_service_hash(service_hash)
  #
  #
  #    service_hash[:publisher_namespace] = "EnginesSystem"
  #             service_hash[:service_type]='backup'
  #    return service_hash
  #   end

end