require 'yajl'

def convert_json_message_to_hash(request)
    require 'yajl'
   hash_request = JSON.parse(request)
    return  symbolize_top_level_keys(hash_request)
  rescue 
      return nil
  end
  
  def symbolize_top_level_keys(hash)
      hash.inject({}){|result, (key, value)|
        new_key = case key
        when String then key.to_sym
        else key
        end
 #       new_value = case value
#        when Hash then symbolize_keys(value)
#        when Array   then
#          newval=Array.new
#          value.each do |array_val|
#            if array_val.is_a?(Hash)
#              array_val = symbolize_keys(array_val)
#            end
#            newval.push(array_val)
#          end
#          newval
#        else value
#        end
        
        result[new_key] = value
        result
      }
    end
  

def wait_for_reply(socket)
#  def process_messages(socket)
  begin
        # while socket.is_open? ==true 
      #blocking read
      #readup to first ,
      #get count
      #sub traact bytes already read and read until the rest.
      #save next segment if there is any (or stay sync)
    first_bytes = socket.read_nonblock(32768)

  end_tag_indx = first_bytes.index(',')

  mesg_lng_str = first_bytes.slice(0,end_tag_indx)

  mesg_len =  mesg_lng_str.to_i
  p :mesg_len
  p mesg_len
  total_length = first_bytes.size
  end_byte =  total_length - end_tag_indx 
  messege_response = first_bytes.slice(end_tag_indx+1,end_byte) 
  
        while messege_response.size < mesg_len
          begin
         more = socket.read_nonblock(32768)
          messege_response = messege_response + more
          rescue IO::EAGAINWaitReadable
            retry
         end
        end 
       
      rescue IO::EAGAINWaitReadable
        retry
     end
  
  response_hash = convert_json_message_to_hash(messege_response)
 
  return response_hash
  
end
def build_mesg(mesg_str)
     header = mesg_str.to_s.length
     return header.to_s + "," + mesg_str.to_s
   end
def send_request(command,params)
  request_hash = params.dup
  request_hash[:command] = command
   request_json = request_hash.to_json
  mesg_str = build_mesg(request_json)
  @registry_socket.write(mesg_str)
  result_hash = wait_for_reply(@registry_socket)
  return result_hash
end



def open_socket(host,port)
   require 'socket.rb' 
  BasicSocket.do_not_reverse_lookup = true
    socket = TCPSocket.new(host,port)  
    
      return socket

end   

@registry_socket= open_socket("127.0.0.1",21027)
require 'yaml'
require 'rubytree'
params=Hash.new

command="list_providers_in_use"
result = send_request(command,params)
p "list_providers_in_use"
p result.to_s

command="system_registry_tree"
result = send_request(command,params)
p "system_registry_tree"
p result[:result]

command="service_configurations_registry"
result = send_request(command,params)
p "service_configurations_registry"
p result[:result]
  p :As_json
  p result[:object].to_s

  p :class_name
config_registry = YAML::load(result[:object])
p config_registry.class.name

command="orphaned_services_registry"
result = send_request(command,params)
p "orphaned_services_registry"
p result[:result]

command="services_registry"
result = send_request(command,params)
p "services_registry"
p result[:result]

command="managed_engines_registry"
result = send_request(command,params)
p "managed_engines_registry"
p result[:result]

 