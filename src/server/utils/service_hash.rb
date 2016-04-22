module ServiceHash
def self.service_hash_from_params(params)
splats = params['splat']
 type_path = File.dirname(splats[0])       
  service_handle = File.basename(splats[0])  
       hash = {}
       hash[:publisher_namespace] = params['ns']       
       hash[:type_path] = type_path
       hash[:service_handle] = service_handle
       hash  
end

def self.engine_service_hash_from_params(params)
 hash = self.service_hash_from_params(params)
 hash[:parent_engine] = params['engine_name']
 hash[:container_type] = 'container'
 hash
end

def self.service_service_hash_from_params(params)
   hash = self.service_hash_from_params(params)
   hash[:parent_engine] = params['service_name'] 
   hash[:container_type] = 'service'
    return hash  
end
end