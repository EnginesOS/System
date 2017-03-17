module EngineApiErrors
  require_relative 'engine_api_error.rb'
  def log_warn_mesg(mesg,*objs)
    EngineApiError.new(mesg.to_s,:warning)
  end

  def log_error_mesg(mesg,*objs)
    super
    EngineApiError.new(mesg.to_s,:failure)
  end

  def log_exception(e,*objs)
    super
    EngineApiError.new(e.to_s,:exception)
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
       system: :container_api,
       params: params }
   end

  
end