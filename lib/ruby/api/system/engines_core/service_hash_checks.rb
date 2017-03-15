require '/opt/engines/lib/ruby/exceptions/engines_exception.rb'

module ServiceHashChecks
  def check_engine_hash(service_hash)
    check_hash(service_hash)
    # FIXME: Kludge
    # Klugde to avoid gui bugss
    #    unless service_hash.key?(:parent_engine)
    #      service_hash[:parent_engine] = service_hash[:engine_name]
    #    end
    service_hash[:container_type] = "container" unless service_hash.key?(:container_type)
    # End of Kludge
    raise EnginesException.new({error_mesg: 'No parent engine',  error_type: :error , params: service_hash}) unless service_hash.key?(:parent_engine)
    raise EnginesException.new({error_mesg: 'nil parent_engine',  error_type: :error , params: service_hash}) if service_hash[:parent_engine].nil? || service_hash[:parent_engine] == ''
    raise EnginesException.new({error_mesg: 'No container type path',  error_type: :error , params: service_hash}) unless service_hash.key?(:container_type)
    raise EnginesException.new({error_mesg: 'nil container type path',  error_type: :error , params: service_hash})  if service_hash[:container_type].nil? || service_hash[:container_type] == ''
    true
  end

  def check_sub_service_hash(service_hash)
    r = ''
    check_service_hash(service_hash)
    raise EnginesException.new({error_mesg: 'No parent service',  error_type: :error , params: service_hash}) unless service_hash.key?(:parent_service)
    true
  end

  def check_engine_service_hash(service_hash)
    check_engine_service_query(service_hash)
    raise EnginesException.new({error_mesg: 'No service variables', error_type: :error , params: service_hash}) unless service_hash.key?(:variables)
    true
  end

  def check_engine_service_query(service_hash)
    check_service_hash(service_hash)
    check_engine_hash(service_hash)
    true
  end

  def check_hash(service_hash)
    raise EnginesException.new({error_mesg: 'Nil service Hash',error_type: :error , params: service_hash}) if service_hash.nil?
    raise EnginesException.new({error_mesg: 'Not a Service Hash as not a hash',error_type: :error , params: service_hash})  unless service_hash.is_a?(Hash)
    true
  end

  def check_service_hash(service_hash)
    check_hash(service_hash)
    raise EnginesException.new({error_mesg: 'No publisher name space',error_type: :error , params: service_hash}) unless service_hash.key?(:publisher_namespace)
    raise EnginesException.new({error_mesg: 'nil publisher name space', error_type: :error , params: service_hash}) if service_hash[:publisher_namespace].nil? || service_hash[:publisher_namespace] == ''
    raise EnginesException.new({error_mesg: 'No type path', error_type: :error , params: service_hash}) unless service_hash.key?(:type_path)
    raise EnginesException.new({error_mesg: 'nil type path', error_type: :error , params: service_hash}) if service_hash[:type_path].nil? || service_hash[:type_path] == ''
    true
  end

end