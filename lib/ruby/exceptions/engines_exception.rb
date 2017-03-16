class EnginesException < StandardError
  attr_reader :level, :params, :status
  def initialize(msg="Engines Exception", level=:error, *params)
    @level = level
    @params = params
    super(msg)
  end

  def initialize( hash)
   if hash.is_a?(Hash)
      @level = hash[:error_type].to_sym
      @params = hash[:params]
      super(hash[:error_mesg])
    else      
     @level = :nil
     super(hash.to_s)      
    end   
  end

end