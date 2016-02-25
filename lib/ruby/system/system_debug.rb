class SystemDebug
  
  
              
  @@debug_flags=0
  
  @@services = 1
  @@orphans = 2
  @@environment = 4
  @@templater = 8
  @@builder = 32
  @@execute = 64
  
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
    mask = args[0]
   self.print_debug(args) unless mask & @@debug_flags == 0
  end
  
  def self.print_debug(args)
    mesg = 'Debug:'
    args.each do |arg|
      mesg += arg.to_s + ' '
    end
    SystemUtils.log_output(mesg,20)
  end
  
end