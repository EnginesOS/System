#@return [Hash] completed dns service_hash for engine on the engines.internal dns for
#@param engine [ManagedContainer]
#def hostname(engine)
#
#end

def engine_hostname(engine)
  if engine.ctype == 'service'
    engine.hostname
  else
    engine.container_name
  end
end

def create_dns_service_hash(engine)
  service_hash = {
    publisher_namespace: 'EnginesSystem',
    type_path: 'dns',
    persistent: false,
    service_container_name: 'dns',
    parent_engine: engine.container_name,
    container_type: engine.ctype,
    service_handle: engine.container_name,
    variables: {
    parent_engine: engine.container_name,
    hostname: engine_hostname(engine),
    name: engine_hostname(engine),
    ip: engine.get_ip_str.to_s },
    overwrite: true
  }
  SystemDebug.debug(SystemDebug.services,  service_hash.to_s)
  service_hash
end

def create_zeroconf_service_hash(engine)
  service_hash = {
    publisher_namespace: 'EnginesSystem',
    type_path: 'avahi',
    persistent: false,
    service_container_name: 'avahi',
    parent_engine: engine.container_name,
    container_type: engine.ctype,
    service_handle: engine.container_name,
    variables: {
    parent_engine: engine.container_name,
    hostname: engine_hostname(engine),
    name: engine_hostname(engine),
    overwrite: true
    }
  }
  SystemDebug.debug(SystemDebug.containers, :created_zeroconfdns_service_hash, service_hash)
  service_hash
end

#@return [Hash] completed nginx service_hash for engine on for the default website configured for
#@param engine [ManagedContainer]

def create_nginx_service_hash(engine)
  proto =  'http_https'
  case engine.protocol.to_s
  when 'https_only'
    proto = 'https'
  when 'http_and_https'
    proto = 'http_https'
  when 'https_and_http'
    proto = 'https_http'
  when 'http_only'
    proto = 'http'
  end

  service_hash = {
    persistent: false,
    service_container_name: 'nginx',
    type_path: 'nginx',
    publisher_namespace: 'EnginesSystem',
    service_handle:  engine.fqdn,
    parent_engine: engine.container_name,
    container_type: engine.ctype,
    variables: {
    parent_engine: engine.container_name,
    internal_dir: '/',
    engine_count: 1,
    public: 1,
    name: engine.container_name,
    fqdn: engine.fqdn,
    port: engine.web_port.to_s,
    proto: proto,
    www_path: web_path(engine)
    }
  }
  unless  engine.ctype == 'service'
    service_hash[:variables][:www_path] = engine.web_root.to_s unless engine.web_root.to_s == ''
  else
    service_hash[:variables][:www_path] = ''
  end

  SystemDebug.debug(SystemDebug.services,'create nginx Hash',service_hash)
  service_hash
end

def web_path(engine)
  unless  engine.ctype == 'service'
    r = engine.web_root.to_s unless engine.web_root.to_s == ''
  else
    r = '' #service_hash[:variables][:www_path] = ''
  end
   r
end
