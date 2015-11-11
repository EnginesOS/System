class EnvironmentVariable
  def initialize(name, value, setatrun, mandatory, build_time_only,label, immutable)
    #name,value,ask,mandatory,build_time_only
    @name = name
    @value = value
    @ask_at_build_time = setatrun
    @build_time_only = build_time_only
    @mandatory = mandatory
    @label = label
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
  :immutable,
  :has_changed
  attr_accessor :value

  def attributes
    retval = {}
    retval[:name] = @name
    retval[:label] = @label
    retval[:value] = @value
    retval[:ask_at_build_time] = @ask_at_build_time
    retval[:build_time_only] = @build_time_only
    retval[:mandatory] = @mandatory
    retval[:immutable] = @immutable
    retval[:changed] = @has_changed
    return retval
  end

  # Replace any envs in dest [Array] that exist in fresh_envs [Array] and add any new
  # the members or teh arrays are EnvironmentVariable match by EnvironmentVariable.name
  def self.merge_envs(fresh_envs,dest)
    fresh_envs.each do |new_env|
      r = self.find_env_in(new_env,dest)
      dest.delete(r) unless r.nil?
      dest.push(new_env)
    end
    return dest
  end

  def self.find_env_in(new_env,dest)
    dest.each do  |env|
#      STDERR.puts '+++++++++++++++++++++++++++++'
#      STDERR.puts env.to_s
#      STDERR.puts new_env.to_s
#      STDERR.puts new_env.class.name
      next unless env.is_a?(EnvironmentVariable)
      return env if env.name == new_env.name
    end
    return nil
  end
end
