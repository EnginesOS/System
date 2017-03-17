require '/opt/engines/lib/ruby/system/engines_error.rb'

class EnginesRegistryError < EnginesError
  def initialize(error_hash)
    if error_hash.is_a?(Hash)
      message = error_hash[:error_mesg]
      type = error_hash[:error_type]
      @params = error_hash[:params]
    else
      message = hash.to_s
      type = :error
      @params = []
    end

    super(message, type)
    @sub_system = 'engines_registry'
    @registry_source = error_hash[:source]
  end

  def error_hash(mesg, params = nil)
     r = error_type_hash(mesg, params)
     r[:error_type] = :error
     r
   end
 
   def warning_hash(mesg, params = nil)
     r = error_type_hash(mesg, params)
     r[:error_type] = :warning
     r
   end
 
   def error_type_hash(mesg, params = nil)
     {error_mesg: mesg,
       system: :registry,
       params: params }
   end

end
