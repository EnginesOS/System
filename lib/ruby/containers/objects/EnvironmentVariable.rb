class EnvironmentVariable
  def initialize(name,value,setatrun,mandatory,build_time_only,label,immutable)
    #name,value,ask,mandatory,build_time_only
    @name=name
    @value=value
    @ask_at_build_time=setatrun
    @build_time_only = build_time_only
    @mandatory = mandatory
    @label = label
    @immutable = immutable
    @changed = false
  end
  def setatrun
    return @ask_at_build_time
  end
  attr_reader :ask_at_build_time,:name,:build_time_only,:mandatory,:label,:immutable,:changed
 attr_accessor :value
  def attributes
    retval = Hash.new()
    retval[:name] = @name
    retval[:label] = @label
    retval[:value] = @value
    retval[:ask_at_build_time] = @ask_at_build_time
    retval[:build_time_only] = @build_time_only
    retval[:mandatory] = @mandatory
    retval[:immutable] = @immutable
    retval[:changed] = @changed
    return retval
  end
end