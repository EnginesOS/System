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
  
end