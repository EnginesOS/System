module Containers
  # @param container_log file
  # @param retentioncount
  def rotate_container_log(cid, retention = 10)
    run_server_script('rotate_container_log', "#{cid} #{retention}")
  end

  def save_container(c)
    STDERR.puts "Save #{c.container_name}  #{c.class.name} <=> #{c.ctype} #{c.id} "
    container_store.save(c)
  end
end
