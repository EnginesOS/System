def exposed_ports(container)
  eports = {}
  unless container.mapped_ports.nil?
    container.mapped_ports.each_value do |port|
      port = symbolize_keys(port)
      if port[:port].is_a?(String) && port[:port].include?('-')
        expose_port_range(eports, port)
      else
        add_exposed_port(eports, port)
      end
    end
  end
  eports
end

def port_bindings(container)
  bindings = {}
  unless container.mapped_ports.nil?
    container.mapped_ports.each_value do |port|
      port = symbolize_keys(port)
      if port[:port].is_a?(String) && port[:port].include?('-')
        add_port_range(bindings, port)
      else
        add_mapped_port(bindings, port)
      end
    end
  end
  bindings
end

def add_port_range(bindings, port)
  internal = port[:port].split('-')
  p = internal[0].to_i
  end_port = internal[1].to_i
  while p < end_port
    add_mapped_port(bindings,{:port=> p, :external=>p, :proto_type=>get_protocol_str(port)})
    p+=1
  end
end

def expose_port_range(eports, port)
  internal = port[:port].split('-')
  p = internal[0].to_i
  end_port = internal[1].to_i
  while p < end_port
    add_exposed_port(eports,{:port=> p, :external=>p, :proto_type=>get_protocol_str(port)})
    p+=1
  end
end

def add_mapped_port(bindings, port )
  local_side = port[:port].to_s + '/' + get_protocol_str(port)
  remote_side = []
  remote_side[0] = {}
  remote_side[0]['HostPort'] = port[:external].to_s unless port[:external] == 0
  bindings[local_side] = remote_side
end

def add_exposed_port(eports, port)
  port[:proto_type] = 'tcp' if port[:proto_type].nil?
  if port[:proto_type].downcase.include?('and') || port[:proto_type].downcase == 'both'
    eports[port[:port].to_s + '/tcp'] = {}
    eports[port[:port].to_s + '/udp'] = {}
  else
    eports[port[:port].to_s + '/' + get_protocol_str(port)] = {}
  end
end