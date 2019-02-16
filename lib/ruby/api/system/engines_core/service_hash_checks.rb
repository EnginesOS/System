require '/opt/engines/lib/ruby/exceptions/engines_exception.rb'

module ServiceHashChecks
  def check_engine_hash(service_hash)
    check_hash(service_hash)
    # FIXME: Kludge
    # Klugde to avoid gui bugss
    unless service_hash.key?(:container_type)
     service_hash[:container_type] = "app"        
     #  STDERR.puts('APPLIED KLUDGE no 1')
    end
    # End of Kludge
    raise EnginesException.new({error_mesg: 'No parent engine',  error_type: :error , params: service_hash}) unless service_hash.key?(:parent_engine)
    raise EnginesException.new({error_mesg: 'nil parent_engine',  error_type: :error , params: service_hash}) if service_hash[:parent_engine].nil? || service_hash[:parent_engine].nil?
    raise EnginesException.new({error_mesg: 'No container type path',  error_type: :error , params: service_hash}) unless service_hash.key?(:container_type)
    raise EnginesException.new({error_mesg: 'nil container type path',  error_type: :error , params: service_hash})  if service_hash[:container_type].nil? || service_hash[:container_type].nil?
  end

  def check_sub_service_hash(service_hash)
   # check_service_hash(service_hash)
    check_hash(service_hash)
  # parent _service nopt used raise EnginesException.new({error_mesg: 'No parent service',  error_type: :error , params: service_hash}) unless service_hash.key?(:parent_service)
  end

  def check_engine_service_hash(service_hash)
    check_engine_service_query(service_hash)
    raise EnginesException.new({error_mesg: 'No service variables', error_type: :error , params: service_hash}) unless service_hash.key?(:variables)
  end

  def check_engine_service_query(service_hash)
    check_service_hash(service_hash)
    check_engine_hash(service_hash)
  end

  def check_hash(service_hash)
    raise EnginesException.new({error_mesg: 'Nil service Hash',error_type: :error , params: service_hash}) if service_hash.nil?
    raise EnginesException.new({error_mesg: 'Not a Service Hash is not a hash but a ' + service_hash.class.name, error_type: :error , params: service_hash})  unless service_hash.is_a?(Hash)
  end

  def check_service_hash(service_hash)
    check_hash(service_hash)
    raise EnginesException.new({error_mesg: 'No publisher name space',error_type: :error , params: service_hash}) unless service_hash.key?(:publisher_namespace)
    raise EnginesException.new({error_mesg: 'nil publisher name space', error_type: :error , params: service_hash}) if service_hash[:publisher_namespace].nil? || service_hash[:publisher_namespace].nil?
    raise EnginesException.new({error_mesg: 'No type path', error_type: :error , params: service_hash}) unless service_hash.key?(:type_path)
    raise EnginesException.new({error_mesg: 'nil type path', error_type: :error , params: service_hash}) if service_hash[:type_path].nil? || service_hash[:type_path].nil?
  end

  def check_new_service_hash(service_hash)
    check_service_hash(service_hash)
    raise EnginesException.new({error_mesg: 'No :service_handle',error_type: :error , params: service_hash}) unless service_hash.key?(:service_handle)
    raise EnginesException.new({error_mesg: 'No :variables',error_type: :error , params: service_hash}) unless service_hash.key?(:variables)
    raise EnginesException.new({error_mesg: 'illegals chars in :service_handle [ a-zA-Z0-9_+.] only ' + service_hash[:service_handle].to_s ,error_type: :error, params: service_hash}) unless service_hash[:service_handle].match(/^[ a-zA-Z0-9_.+]+$/)
  end
end