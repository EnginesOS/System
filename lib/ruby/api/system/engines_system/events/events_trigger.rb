module EventsTrigger
  
  def trigger_engine_event(engine, status, action)
  
    trigger_event_notification( {
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
           }
         }, 
  })
end
  
def trigger_install_event(engine_name, status) 
  trigger_event_notification({
   status: status,
   id: -1,
   from: engine_name, 
   Type: "container", 
   Action: 'install', 
    Actor:
       {ID: "system", 
         Attributes: 
          {container_name: engine_name, 
            container_type: 'app',
          }
        }, 
 })
end
def trigger_engines_update_event(status)
   trigger_event_notification( {
   status: status,
   id: 'system',
   from: 'system', 
   Type: 'system', 
   Action: 'update'}) 
end
def trigger_engines_restart_event(status)
   trigger_event_notification( {
   status: status,
   id: 'system',
   from: 'system', 
   Type: 'system', 
   Action: 'restart'}) 
end
 
def trigger_system_update_event(status)
   trigger_event_notification( {
   status: status,
   id: 'system',
   from: 'system', 
   Type: 'system', 
   Action: 'system update'}) 
end
end