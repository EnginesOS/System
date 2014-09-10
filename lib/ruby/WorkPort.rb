class WorkPort
  def initialize(name,num,external,publicport,type)
    @name=name
    @port=num
    @external=external
    @publicFacing=publicport
    @proto_type = type #'tcp' or 'udp'
  end

  def proto_type
      @proto_type
  end
    
  def set_proto_type newtype
    @proto_type = newtype
  end
  def name
    return @name
  end
  
  def port
    return @port
  end
  
  def external
    @external    
  end
  
  def publicFacing
    return @publicFacing
  end  
end