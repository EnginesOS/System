class EventMask

  @@container_event = 1
  @@engine_target  = 2
  @@service_target = 4
  @@container_exec = 8
  @@container_action = 16
  @@image_event = 32
  @@container_commit = 64
  @@container_delete = 128
  @@container_kill = 256
  @@container_die = 512
  @@container_event = 1024
  @@container_pull = 2048
  @@build_event = 4096
  @@container_attach = 8192
  @@utility_target = 16384  
  @@service_action = @@container_action | @@service_target
  @@engine_action = @@container_action | @@engine_target
  def self.event_mask(event_hash)
    mask = 0
    if event_hash[:Type] = 'container'
      mask |= @@container_event
      if event_hash.key?(:from)
        return mask |= @@build_event if event_hash[:from].nil?
        return mask |= @@build_event if event_hash[:from].length == 64
        if event_hash[:container_type] == 'service'
          mask |= @@service_target
        elsif event_hash[:container_type] == 'container'
          mask |= @@engine_target
        elsif event_hash[:container_type] == 'utility'
          mask |= @@utility_target
        end
      end
      return 0 if event_hash[:status].nil?

      if event_hash[:status].start_with?('exec')
        mask |= @@container_exec
      elsif event_hash[:status] == 'delete'
        mask |= @@container_delete| @@container_action
      elsif event_hash[:status] == 'destroy'
        mask |= @@container_delete | @@container_action
      elsif event_hash[:status] == 'commit'
        mask |= @@container_commit
      elsif event_hash[:status] == 'pull'
        mask |= @@container_pull
        #        elsif event_hash['status'] == 'delete'
        #          mask |= @@container_delete
      elsif event_hash[:status] == 'die'
        mask |= @@container_die| @@container_action
      elsif event_hash[:status] == 'kill'
        mask |= @@container_kill| @@container_action
      elsif event_hash[:status] == 'attach'
        mask |= @@container_attach
      else
        mask |= @@container_action
      end
    elsif event_hash[:Type] = 'image'
      mask |= @@image_event
    elsif event_hash[:Type] = 'network'
      mask |= @@network_event
    end
    mask
  rescue StandardError => e
    SystemDebug.debug(SystemDebug.container_events, event_hash.to_s + ':' + e.to_s + ':' +  e.backtrace.to_s)
    e
  end
end
