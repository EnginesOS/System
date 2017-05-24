class EnginesException < StandardError
  attr_reader :level, :params, :status, :module, :system, :error_mesg
  def initialize(msg="Engines Exception", level=:error, *params)
    @level = level
    @params = params
    super(msg)
  end

  def initialize(hash)
    if hash.is_a?(Hash)
      # STDERR.puts('Exception from  json' + hash.to_s)
      hash[:error_type] = :error unless hash.key?(:error_type)
      @level = hash[:error_type].to_sym
      @params = hash[:params]
      if hash.key?(:source)
        @source = hash[:source]
      else
        @source = caller[0..10].to_s
      end
      @system = hash[:system]
      @module = hash[:module]
      @status = hash[:status]
      @error_mesg = hash[:error_mesg]
      super(hash[:error_mesg])
    else
      @level = :nil
      super(hash.to_s)
    end
  end

  def to_h
    self.instance_variables.each_with_object({}) { |var, hash| hash[var.to_s.delete("@")] = self.instance_variable_get(var) }
  end

  def is_a_warning?
    return false unless @level == :warning
    true
  end
end