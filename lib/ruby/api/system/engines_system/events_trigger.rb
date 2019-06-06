module EventsTrigger
  
  def trigger_event(engine, status, action)
  
 trigger_container_event( {
    status: status,
    id: engine.container_id,
    from: engine.container_name, 
    Type: "container", 
    Action: action, 
     Actor:
        {ID: "system", 
          Attributes: 
           {container_name: engine.container_name, 
             container_type: engine.ctype,
  #           image: "elasticsearch",
  #           name: "elasticsearch", 
  #           signal: "15"
           }
         }, 
  #   scope: "local",
  #   time: 1559794578,
  #   timeNano: 1559794578908591607
  })
end

end