class WorkPort
  def initialize(name,num,external,publicport,type)
    @name=name
    @port=num
    @external=external
    @publicFacing=publicport
    @proto_type = type #'tcp' or 'udp'
  end
  attr_accessor :proto_type  #need to set if nil can drop this to reader in latter versions
  attr_reader :name,:port,:external,:publicFacing

end