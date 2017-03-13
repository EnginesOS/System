class RegistryException < StandardError
  attr_reader :level, :params, :status
  def initialize(msg="Engines Exception", level=:error, *params)
    @level = level
    @params = params
    super(msg)
  end

  def initialize( hash)
  unless hash.nil?
      @status = status
      @level = hash[:error_type]
      @params = hash[:params]
      super(hash[:error_mesg])
    else
      @level = :nil
      super
    end
  end

end