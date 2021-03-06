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
  @@export_import = 65536
  @@server = 131072
  @@registry = 262144
  @@schedules = 524288
  @@all_debug_flags = @@execute |@@engine_tasks |@@first_run |@@docker |@@containers|@@container_events| @@services | @@orphans |@@environment |@@templater | @@builder |@@system  |@@cache |@@update|@@registry |@@actions


  if File.exist?('/opt/engines/etc/debug/debug_flags.rb')
    @@debug_flags = 0
    require '/opt/engines/etc/debug/debug_flags.rb'
  else
    @@debug_flags = 0
     @@debug_flags = @@builder | @@first_run#|@@docker  | @@execute#|@@export_import| @@services #|@@container_events |@@export_import |@@orphans # @@builder | @@templater | @@services # @@first_run | @@actions | @@orphans#  |@@container_events # |@@containers #|@@services  | @@container_events #|@@containers |@@engine_tasks # |@@builder |  @@container_events #  |  # @@first_run  |@@builder # @@actions# @@docker# @@builder  | @@docker | @@services | @@registry |@@containers
    #   @@debug_flags =  @@orphans| @@first_run # @@schedules#| @@services | @@registry
    #  @@debug_flags =  @@container_events| @@builder|@@templater| @@services | @@export_import# |@@first_run # @@containers# |@@container_events |@@first_run # @@orphans | @@builder |@@export_import | @@services| @@container_events|  @@server |@@templater| @@services | @@export_import |@@builder|@@execute|@@engine_tasks | @@orphans  |@@containers
  end

  def self.schedules
    @@schedules
  end

  def self.registry
    @@registry
  end

  def self.server
    @@server
  end

  def self.export_import
    @@export_import
  end

  def self.container_events
    @@container_events
  end

  def self.actions
    @@actions
  end

  def self.update
    @@update
  end

  def self.registry
    @@registry
  end

  def self.cache
    @@cache
  end

  def self.engine_tasks
    @@engine_tasks
  end

  def self.containers
    @@containers
  end

  def self.first_run
    @@first_run
  end

  def self.system
    @@system
  end

  def self.docker
    @@docker
  end

  def self.services
    @@services
  end

  def self.orphans
    @@orphans
  end

  def self.environment
    @@environment
  end

  def self.templater
    @@templater
  end

  def self.builder
    @@builder
  end

  def self.execute
    @@execute
  end

  def self.debug(*args)
    unless @@debug_flags == 0
      mask = args[0]
      unless mask & @@debug_flags == 0
        self.print_debug(args)
      else
        true
      end
    end
  end

  def self.print_debug(args)
    mesg = "Debug:#{caller[1]}:"
    args.each do |arg|
      mesg += "#{arg} "
    end
    STDERR.puts(mesg )
  end

end