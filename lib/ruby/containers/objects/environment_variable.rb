class EnvironmentVariable
  def initialize(name, value, setatrun = false, mandatory=false, build_time_only = false, label = nil, immutable = false, owner = nil)
    #name,value,ask,mandatory,build_time_only
    
    label = name if label.nil?
    @name = name
    @value = value
    @ask_at_build_time = setatrun
    @build_time_only = build_time_only
    @mandatory = mandatory
    @label = label
      unless owner.nil?
        @owner_type = owner[0]
        @owner_path = owner[1]
      else
        @owner_path = ''
        @owner_type = 'application'# |service_consumer |system
      end
    
    @immutable = immutable
    @has_changed = true
  end
  
  

  def setatrun
    return @ask_at_build_time
  end
  attr_reader :ask_at_build_time,
  :name,
  :build_time_only,  
  :mandatory,
  :label,
  :owner_type,
  :owner_path,
  :immutable,
  :has_changed
  attr_accessor :value

  def attributes
    retval = {}
    retval[:name] = @name
    retval[:label] = @label
    retval[:value] = @value
    retval[:owner_type]  = @owner_type
    retval[:owner_path] =  @owner_path 
    retval[:ask_at_build_time] = @ask_at_build_time
    retval[:build_time_only] = @build_time_only
    retval[:mandatory] = @mandatory
    retval[:immutable] = @immutable
    retval[:changed] = @has_changed
    return retval
  end

  # Replace any envs in dest [Array] that exist in fresh_envs [Array] and add any new
  # the members or the arrays are EnvironmentVariable match by EnvironmentVariable.name
  def self.merge_envs(fresh_envs, dest)

    fresh_envs.each do |new_env|
      r = self.find_env_in(new_env, dest)
      dest.delete(r) unless r.nil?
      dest.push(new_env)
    end

    return dest
  end
  def to_h
   
   # STDERR.puts('to hash ENVASDASD')
    self.attributes
end
  def self.find_env_in(new_env,dest)
    dest.each do  |env|

      next unless env.is_a?(EnvironmentVariable)
      return env if env.name == new_env.name
    end
    return nil
  end
end
