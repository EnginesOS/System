class EnginesPublicApiError < EnginesError
  
  
  def initialize(message, type = :fail)
     super
     @source = caller[1].to_s 
     @sub_system = 'engine_public_api'
   end
   
end

