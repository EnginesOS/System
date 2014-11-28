class WorkPort
  def initialize(name,num,external,publicport,type)
    @name=name
    @port=num
    @external=external
    @publicFacing=publicport
    @proto_type = type #'tcp' or 'udp'
  end

  attr_reader :proto_type,:name,:port,:external,:publicFacing

end