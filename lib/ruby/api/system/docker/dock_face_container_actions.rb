module DockFaceContainerActions
  def start_container(cid)
    if cid.nil?
      EnginesDockFaceError.new('Missing Container id', :warning)
    else
      post({uri: "/containers/#{cid}/start"})
    end
  end

  def pause_container(cid)
    if cid.nil?
      EnginesDockFaceError.new('Missing Container id', :warning)
    else
      post({uri: "/containers/#{cid}/pause"})
    end
  end

  def unpause_container(cid)
    if cid.nil?
      EnginesDockFaceError.new('Missing Container id', :warning)
    else
      post({uri: "/containers/#{cid}/unpause"})
    end
  end

  def stop_container(cid, to = 25)
    post({uri: "/containers/#{cid}/stop?t=#{to}"})
  end
end