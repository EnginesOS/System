class EnvironmentVariable
  def initialize(name,value,setatrun,mandatory,build_time_only,label)
    #name,value,ask,mandatory,build_time_only
    @name=name
    @value=value
    @set_at_build_time=setatrun
    @build_time_only = build_time_only
    @mandatory = mandatory
    @setatrun = @set_at_build_time #Kludge so as noto break Guo should be removed when gui fixed
    @label = label
  end
  
  attr_reader :set_at_build_time,:name,:value,:build_time_only,:mandatory,:label,:setatrun
  
  def attributes
    retval = Hash.new()
    retval[:name] =  @name
    retval[:label]= @label
    retval[:value]=@value
    retval[:set_at_build_time] =   @set_at_build_time
    retval[:build_time_only]=@build_time_only 
    retval[:mandatory]=@mandatory 
      
      return retval
  end
end