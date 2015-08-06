class NetworkSystemRegistry

  require 'json'

  def initialize(server,port)
    @registry_socket = open_socket(server,port)
  end

  def  find_engine_services(params)
    send_request("find_engine_services",params)
  end

  def  find_engine_services_hashes(params)
    send_request("find_engine_services_hashes",params)
  end

  def get_engine_nonpersistant_services(params)
    send_request("get_engine_nonpersistant_services",params)
  end

  def get_engine_persistant_services(params)
    send_request("get_engine_persistant_services",params)
  end

  def remove_from_managed_engines_registry(service_hash)
    send_request("remove_from_managed_engines_registry",service_hash)
  end

  def add_to_managed_engines_registry(service_hash)
    send_request("add_to_managed_engines_registry",service_hash)
  end

  #
  def save_as_orphan(params)
    send_request("save_as_orphan",params)
  end

  def release_orphan(params)
    send_request("release_orphan",params)
  end

  #
  def reparent_orphan(params)
    send_request("reparent_orphan",params)
  end

  #
  def retrieve_orphan(params)
    send_request("retrieve_orphan",params)
  end

  #
  def get_orphaned_services(params)
    send_request("get_orphaned_services",params)
  end

  #
  def find_orphan_consumers(params)
    send_request("find_orphan_consumers",params)
  end

  #
  def orphan_service(service_hash)
    send_request("orphan_service",service_hash)
  end

  #
  #
  def  find_service_consumers(service_query_hash)
    send_request("find_service_consumers",service_query_hash)
  end

  #
  def  update_attached_service(service_hash)
    send_request("update_attached_service",service_hash)
  end

  #
  def  add_to_services_registry(service_hash)
    send_request("add_to_services_registry",service_hash)
  end

  #
  def  remove_from_services_registry(service_hash)
    send_request("remove_from_services_registry",service_hash)
  end

  #
  def  service_is_registered?(service_hash)
    send_request("service_is_registered?",service_hash)
  end

  #
  def  get_registered_against_service(params)
    send_request("get_registered_against_service",params)
  end

  #
  #
  def  get_service_configurations_hashes(service_hash)
    send_request("get_service_configurations_hashes",service_hash)
  end

  #
  def  update_service_configuration(config_hash)
    send_request("update_service_configuration",config_hash)
  end

  #
  def  list_providers_in_use
    send_request("list_providers_in_use",nil)
  end

  #
  #
  def  system_registry_tree
    send_request("system_registry_tree",nil)
  end

  #
  def  service_configurations_registry
    send_request("service_configurations_registry",nil)
  end

  #
  def  orphaned_services_registry
    send_request("orphaned_services_registry",params)
  end

  #
  def  services_registry
    send_request("services_registry",params)
  end

  #
  def  managed_engines_registry
    send_request("managed_engines_registry",params)
  end

  private

  def convert_json_message_to_hash(request)
    require 'json'
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

  protected

  def open_socket(host,port)
    require 'socket.rb'
    BasicSocket.do_not_reverse_lookup = true
    socket = TCPSocket.new(host,port)

    return socket

  end
end