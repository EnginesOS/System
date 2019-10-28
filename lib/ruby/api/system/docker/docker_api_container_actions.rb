module DockerApiContainerActions
  def start_container(cid)
    if cid.to_s == '-1' || cid.to_s  == ''
      EnginesDockerApiError.new('Missing Container id', :warning)
    else
      post({uri: "/containers/#{cid}/start"})
    end
  end

  def pause_container(cid)
    if cid.to_s == '-1' || cid.to_s  == ''
      EnginesDockerApiError.new('Missing Container id', :warning)
    else
      post({uri: "/containers/#{cid}/pause"})
    end
  end

  def unpause_container(cid)
    if cid.to_s == '-1' || cid.to_s  == ''
      EnginesDockerApiError.new('Missing Container id', :warning)
    else
      post({uri: "/containers/#{cid}/unpause"})
    end
  end

  def stop_container(cid, to = 25)
    post({uri: "/containers/#{cid}/stop?t=#{to}"})
  end
end