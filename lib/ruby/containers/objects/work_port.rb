class WorkPort
  def self.work_port_hash(name, num, external, publicport, type)
    r = {
      port_name: name,
      port: num,
      external: external,
      public_facing: publicport, # boolean
      proto_type: type # 'tcp' or 'udp' or both
    }
  end

end