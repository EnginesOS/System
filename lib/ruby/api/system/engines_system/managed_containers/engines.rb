require '/opt/engines/lib/ruby/containers/store/store'

module Engines
#  class FakeContainer
#    attr_reader :container_name, :ctype
#    def initialize(name, type = 'app')
#      @container_name = name
#      @ctype = type
#    end
#  end

  def list_managed_engines
    ret_val = []
    begin
      Dir.entries(SystemConfig.RunDir + '/apps/').each do |contdir|
        yfn = SystemConfig.RunDir + '/apps/' + contdir + '/running.yaml'
        ret_val.push(contdir) if File.exist?(yfn)
      end
    rescue
    end
    ret_val
  end

  def set_engine_network_properties(engine, params)
    set_engine_hostname_details(engine, params) if set_engine_web_protocol_properties(engine, params)
  end

  def set_engine_web_protocol_properties(engine, params)
    protocol = params[:http_protocol]
    raise EnginesException.new(error_hash('no protocol field')) if protocol.nil?
    protocol.downcase
    protocol.gsub!(/ /,"_")
   # SystemDebug.debug(SystemDebug.services,'Changing protocol to _', protocol)
    if protocol.include?('https_only')
      engine.enable_https_only
    elsif protocol.include?('http_only')
      engine.enable_http_only
    elsif protocol.include?('https_and_http')
      engine.enable_https_and_http
    elsif protocol.include?('http_and_https')
      engine.enable_http_and_https
    end
    true
  end

  def set_engine_hostname_details(container, params)
        p :set_engine_network_properties
        p container.container_name
        p params
    #FIXME change port
    #FIXME change proto
    #FIXME [:hostname]  silly host_name from gui drop it
    if params.key?(:host_name)
      hostname = params[:host_name]
    else
      hostname = params[:hostname]
    end
    domain_name = params[:domain_name]
#    SystemDebug.debug(SystemDebug.services,'Changing Domainame to ', domain_name)
    container.remove_wap_service
    container.set_hostname_details(hostname, domain_name)
    container.save_state
    container.add_wap_service
    true
  end

  def getManagedEngines
    ret_val = []
    Dir.entries(SystemConfig.RunDir + '/apps/').each do |contdir|
      yfn = SystemConfig.RunDir + '/apps/' + contdir + '/running.yaml'
      if File.exist?(yfn)
        begin
          managed_engine = loadManagedEngine(contdir)
          ret_val.push(managed_engine)
        rescue
        end
      end
    end
    ret_val
  end

  def loadManagedEngine(engine_name)
    store.model(engine_name)
  end

  protected

  def store
    Container::Store.instance
  end

end
