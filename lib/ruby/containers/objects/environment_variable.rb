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

  def initialize(env_hash)
    @name = env_hash[:name]
    @value = env_hash[:value]
    if env_hash.key?(:ask_at_build_time)
     @ask_at_build_time = env_hash[:ask_at_build_time]
    else
      @ask_at_build_time = false
    end
    if env_hash.key?(:build_time_only)
     @build_time_only = env_hash[:build_time_only]
    else
      @build_time_only = false
    end   
    if env_hash.key?(:mandatory)
    @mandatory = env_hash[:mandatory]
    else
      @mandatory = false
    end  
    @label = env_hash[:label] if env_hash.key?(:label)
    if env_hash.key?(:owner_type)
      @owner_type = env_hash[:owner_type] 
      @owner_path = env_hash[:owner_path] if env_hash.key?(:owner_path)
    else
      @owner_path = ''
      @owner_type = 'application'# |service_consumer |system
    end
    if env_hash.key?(:immutable)
    @immutable = env_hash[:immutable]
    else
      @immutable = false
    end
    @has_changed = true
  end

  def setatrun
    @ask_at_build_time
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
  attr_accessor :value, :name

  def attributes
    {
      name: @name,
      label: @label,
      value: @value,
      owner_type: @owner_type,
      owner_path:  @owner_path,
      ask_at_build_time: @ask_at_build_time,
      build_time_only: @build_time_only,
      mandatory: @mandatory,
      immutable: @immutable,
      changed: @has_changed
    }
  end

  # Replace any envs in dest [Array] that exist in fresh_envs [Array] and add any new
  # the members or the arrays are EnvironmentVariable match by EnvironmentVariable.name
  def self.merge_envs(fresh_envs, dest)
    fresh_envs.each do |new_env|
      r = self.find_env_in(new_env, dest)
      dest.delete(r) unless r.nil?
      dest.push(new_env)
    end
    dest
  end

  def to_h
    self.attributes
  end

  def self.find_env_in(new_env, dest)
    r = nil
    dest.each do  |env|
      next unless env.is_a?(EnvironmentVariable)
      if env.name == new_env.name
        r = env
        break
      end
    end
    r
  end
end
