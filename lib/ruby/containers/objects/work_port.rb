class WorkPort
  def self.work_port_hash(name, num, external, publicport, type)
    r = {}
    r[:port_name] = name
    r[:port] = num
    r[:external] = external 
    r[:public_facing] = publicport # boolean
    r[:proto_type] = type # 'tcp' or 'udp' or both
      r
  end


end