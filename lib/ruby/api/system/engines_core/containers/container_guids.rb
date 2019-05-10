module ContainerGuids
  def new_container_uid(container_name)
    uid = read_historical_id(container_name)
    uid = next_id(container_name) if uid == -1
    uid
  end

  def new_data_uid(container_name)
    '1111'
  end

  def new_data_gid(container_name)
    '1111'
  end

  private

  def read_historical_id(container_name)
    if File.exist?(SystemConfig.ContainerUIDdir + '/' + container_name.to_s)
      id_file = File.new(SystemConfig.ContainerUIDdir + '/' + container_name.to_s,'r')
      begin
        uid_s =  id_file.read
      ensure
        id_file.close
      end
      uid_s.strip
      uid_s.to_i
    else
      -1
    end
  end

  def next_id(container_name)
    if File.exist?(SystemConfig.ContainerNextUIDFile)
      next_id_file = File.new(SystemConfig.ContainerNextUIDFile,'r')
      begin
        uid_s =  next_id_file.read
      ensure
        next_id_file.close
      end
      uid_s.strip
      uid = uid_s.to_i
    else
      uid = 100000
    end
    save_container_id(uid, container_name)
    inc_uid_file(uid)
    uid
  end

  def save_container_id(uid, container_name)
    id_file = File.new(SystemConfig.ContainerUIDdir + '/' + container_name.to_s,'w+')
    begin
      id_file.puts(uid.to_s)
    ensure
      id_file.close
    end
  end

  def inc_uid_file(uid)
    next_id_file = File.new(SystemConfig.ContainerNextUIDFile,'w+')
    begin
      uid = uid + 1
      next_id_file.puts(uid.to_s)
    ensure
      next_id_file.close
    end
  end

end