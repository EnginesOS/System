class WorkPort
  def initialize(name,num,external,publicport)
    @name=name
    @port=num
    @external=external
    @publicFacing=publicport
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