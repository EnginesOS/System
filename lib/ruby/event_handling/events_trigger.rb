class EventHandler
  def trigger_engine_event(engine, status, action)
    if engine.nil?
      trigger_event_notification( {
        status: status,
        id: -1,
        from: 'builder',
        Type: 'container',
        Action: action,
        Actor:
        {ID: 'system',
        Attributes:
        {container_name: 'build',
        container_type: :app,
        }
        },
      })
    else
      trigger_event_notification( {
        status: status,
        id: engine.id,
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
  end

  def trigger_install_event(engine_name, status)
    trigger_event_notification({
      status: status,
      id: 'system',
      from: 'system',
      Type: 'system',
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
      Action: 'update',
      Actor:
      {ID: 'system',
      Attributes:
      {container_name: 'system',
      container_type: 'system',
      }
      },})
  end

  def trigger_engines_restart_event(status)
    trigger_event_notification( {
      status: status,
      id: 'system',
      from: 'system',
      Type: 'system',
      Action: 'restart',
      Actor:
      {ID: 'system',
      Attributes:
      {container_name: 'system',
      container_type: 'system',
      }
      },})
  end

  def trigger_system_update_event(status)
    trigger_event_notification( {
      status: status,
      id: 'system',
      from: 'system',
      Type: 'system',
      Action: 'system update',
      Actor:
      {ID: "system",
      Attributes:
      {container_name: 'system',
      container_type: 'system',
      }
      },})
  end
end
