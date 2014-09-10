class WorkPort
  def initialize(name,num,external,publicport,type)
    @name=name
    @port=num
    @external=external
    @publicFacing=publicport
    @type = type #'tcp' or 'udp'
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