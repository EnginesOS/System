class RegistryException < StandardError
  attr_reader :level, :params, :status
    def initialize(msg="Engines Exception", level=:error, *params)
        @level = level
        @params = params
        super(msg)
      end
  def   initialize(status, hash)
    @status = status
        @level = hash[:level]
        @params = hash[:params]           
        super(hash[:msg])
       end
      
end