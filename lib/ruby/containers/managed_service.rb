#require '/opt/engines/lib/ruby/containers/ManagedContainer.rb'
#require 'objspace'
require '/opt/engines/lib/ruby/containers/container.rb'
require '/opt/engines/lib/ruby/containers/managed_container.rb'
class ManagedService < ManagedContainer

  require_relative 'managed_service/managed_service_configurations.rb'
  include    ManagedServiceConfigurations
  require_relative 'managed_service/managed_service_consumers.rb'
  include    ManagedServiceConsumers
  require_relative 'managed_service/managed_service_readers.rb'
  include    ManagedServiceReaders
  require_relative 'managed_service/managed_service_container_info.rb'
  include    ManagedServiceContainerInfo
  require_relative 'managed_service/managed_service_controls.rb'
  include    ManagedServiceControls
  require_relative 'managed_service/managed_service_image_controls.rb'
  include    ManagedServiceImageControls
  require_relative 'managed_service/managed_service_on_action.rb'
  include ManagedServiceOnAction
  @ctype='service'
  @soft_service  = false
  def lock_values
    super
    @ctype = 'service' if @ctype.nil?
    @ctype.freeze
  end

  def ctype
     @ctype
  end

  def is_soft_service?
      return true unless @soft_service.is_a?(FalseClass)
       false
  end

#  def state
#    read_state
#  end

  def initialize(name, memory, hostname, domain_name, image, volumes, web_port, eports, dbs, environments, framework, runtime)
    @last_error = 'None'
    @container_name = name
    @memory = memory
    @hostname = hostname
    @domain_name = domain_name
    @image = image
    @mapped_ports = eports
    @environments = environments
    @volumes = volumes
    @web_port = port
    @last_result = ''
    @setState = 'nocontainer'
    @databases = dbs
    @framework = framework
    @runtime = runtime
    @persistent = false  #Persistant means neither service or engine need to be up/running or even exist for this service to exist
  end
  attr_reader :persistent, :type_path, :publisher_namespace

  def to_service_hash()
    { :publisher_namespace => @publisher_namespace,
      :type_path => @type_path
    }
  
  end
  
  def destroy
    log_error_mesg('Cannot call destroy on a service',self)
  end

  #Sets @last_error to msg + object.to_s (truncated to 256 chars)
  #Calls SystemUtils.log_error_msg(msg,object) to log the error
  #@return none
  def self.log_error_mesg(msg,object)
    obj_str = object.to_s.slice(0,512)
    SystemUtils.log_error_mesg(msg,object)
  end
end
