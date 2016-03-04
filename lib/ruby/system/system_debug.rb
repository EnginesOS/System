class SystemDebug

  @@services = 1
  @@orphans = 2
  @@environment = 4
  @@templater = 8
  @@docker = 16
  @@builder = 32
  @@execute = 64
  @@system = 128
  @@engine_tasks = 256
  @@first_run = 512
  @@containers = 1024
  @@cache = 2048
  @@update = 4096
  @@registry = 8192
  @@actions = 16384
  @@container_events = 32768
  @@all_debug_flags = @@container_events |@@execute  |@@engine_tasks |@@first_run |@@docker  |@@containers| @@services | @@orphans |@@environment |@@templater | @@builder |@@system  |@@cache |@@update|@@registry |@@actions
  #if File.exist?(debug_flag)
   # require(debug_flags)
  #else
  @@debug_flags = @@execute  |@@engine_tasks | @@builder |@@containers |@@docker
  #end
#  @@debug_flags = 0
  def self.container_events
    return @@actions
  end

  def self.actions
    return @@actions
  end

  def self.update
    return @@update
  end

  def self.registry
    return @@registry
  end

  def self.cache
    return @@cache
  end

  def self.engine_tasks
    return @@engine_tasks
  end

  def self.containers
    return @@containers
  end

  def self.first_run
    return @@first_run
  end

  def self.system
    return @@system
  end

  def self.docker
    return @@docker
  end

  def self.services
    return @@services
  end

  def self.orphans
    return @@orphans
  end

  def self.environment
    return @@environment
  end

  def self.templater
    return @@templater
  end

  def self.builder
    return @@builder
  end

  def self.execute
    return @@execute
  end

  def self.debug(*args)
    return true if @@debug_flags == 0
    mask = args[0]
    self.print_debug(args) unless mask & @@debug_flags == 0
    return true
  end

  def self.print_debug(args)
    mesg = 'Debug:'
    args.each do |arg|
      mesg += arg.to_s + ' '
    end
    SystemUtils.log_output(mesg,20)
  end

end