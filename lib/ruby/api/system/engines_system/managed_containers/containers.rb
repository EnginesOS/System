module Containers
  # @param container_log file
  # @param retentioncount
  def rotate_container_log(container_id, retention = 10)
    run_server_script('rotate_container_log', "#{container_id} #{retention}")
  end

  def save_container(c)
    container_store.save(c)
  end
end
