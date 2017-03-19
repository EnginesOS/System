class EnginesException < StandardError
  attr_reader :level, :params, :status, :module, :system
  def initialize(msg="Engines Exception", level=:error, *params)
    @level = level
    @params = params
    super(msg)
  end

  def initialize( hash)
    if hash.is_a?(Hash)
      hash[:error_type] = :error unless hash.key?(:error_type).nil?
      @level = hash[:error_type].to_sym
      @params = hash[:params]
      @source = caller[0..10].to_s
  #    @source = hash[:source]
      @system = hash[:system]
      @module = hash[:module]
      @status = hash[:status]
      super(hash[:error_mesg])
    else
      @level = :nil
      super(hash.to_s)
    end
  end

  def to_h
    self.instance_variables.each_with_object({}) { |var, hash| hash[var.to_s.delete("@")] = self.instance_variable_get(var) }
  end
end