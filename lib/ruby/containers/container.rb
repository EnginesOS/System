require '/opt/engines/lib/ruby/api/system/errors_api.rb'
class Container < ErrorsApi
  
  
  def self.from_yaml(yaml, container_api)
    container = YAML::load(yaml)
    return SystemUtils.log_error_mesg(" Failed to Load yaml ", yaml) if container.nil?
    container.container_api = container_api
    container.post_load
    return container
  rescue Exception => e
    SystemUtils.log_exception(e)
  end
  
  attr_reader :container_id,\
               :memory,\
               :container_name,\
               :image,\
               :web_port,\
               :volumes,\
               :mapped_ports,\
               :environments
  attr_accessor :last_error,\
                :container_api,
                :last_result
  def eports
    @mapped_ports
  end
  
  def post_load
   expire_engine_info
        set_running_user
        lock_values
  end
  def expire_engine_info
    @docker_info_cache = false
    return true
  end
  
  def update_memory(new_memory)
    @memory = new_memory
  end
  
  def read_state
    info = docker_info
    state = 'nocontainer'
            if info[0]['State']
              if info[0]['State']['Running']
                state = 'running'
                if info[0]['State']['Paused']
                  state= 'paused'
                end
              elsif info[0]['State']['Running'] == false
                state = 'stopped'
              else
                state = 'nocontainer'
              end
            end           
           return state
rescue StandardError => e
 log_exception(e)
  end
         
   
  def docker_info
     collect_docker_info if @docker_info_cache.is_a?(FalseClass)    
     return false if @docker_info_cache.is_a?(FalseClass)
     return JSON.parse(@docker_info_cache)
   rescue StandardError => e
    log_exception(e)
   end
 
def has_api?
   return log_error_mesg('No connection to Engines OS System',nil) if @container_api.nil?
   return true
 end
 
def logs_container
  return false unless has_api?
  return @container_api.logs_container(self)
end

def ps_container
  expire_engine_info
  return false unless has_api?
  @container_api.ps_container(self)
end

def is_active?
  state = read_state
  case state
  when 'running'
    return true
  when 'paused'
    return true
  else
    return false
  end
end

# @return a containers ip address as a [String]
# @return nil if exception
# @ return false on inspect container error
def get_ip_str
  expire_engine_info
  return docker_info[0]['NetworkSettings']['IPAddress'] unless docker_info.is_a?(FalseClass)
  return false
rescue
  return nil
rescue StandardError => e
log_exception(e)
end

def is_paused?
  state = read_state
  return true if state == 'paused'
    return false
  end
  
def stats
    expire_engine_info
    return false if docker_info.is_a?(FalseClass)
    started = docker_info[0]['State']['StartedAt']
    stopped = docker_info[0]['State']['FinishedAt']
    ps_container
    pcnt = -1
    rss = 0
    vss = 0
    h = m = s = 0
    @last_result.each_line.each do |line|
      if pcnt > 0 # skip the fist line with is a header
        fields = line.split  #  [6]rss [10] time
        if fields.nil? == false
          rss += fields[7].to_i
          vss += fields[6].to_i
          time_f = fields[11]
          c_HMS = time_f.split(':')
          if c_HMS.length == 3
            h += c_HMS[0].to_i
            m += c_HMS[1].to_i
            s += c_HMS[2].to_i
          else
            m += c_HMS[0].to_i
            s += c_HMS[1].to_i
          end
        end
      end
      pcnt += 1
    end
    cpu = 3600 * h + 60 * m + s
    statistics = ContainerStatistics.new(read_state, pcnt, started, stopped, rss, vss, cpu)
    statistics
rescue => e
log_exception(e)
  end

def is_running?
   state = read_state
   return true if state == 'running'
   return false
 end
 
def has_container?
 # return false if has_image? == false NO Cached
  return false if read_state == 'nocontainer'
  return true
end

def has_image?
  @container_api.image_exist?(@image)
end

def get_container_memory_stats()
  @container_api.get_container_memory_stats(self)
end

def get_container_network_metrics()
  @container_api.get_container_network_metrics(self)
end

def delete_image
  expire_engine_info
  return log_error_mesg('Cannot Delete the Image while container exists. Please stop/destroy first',self) if has_container?  
  return false unless @container_api.delete_image(self)
  expire_engine_info
end

def destroy_container
  expire_engine_info
  return true if read_state == 'nocontainer' 
  return  log_error_mesg('Cannot Destroy a container that is not stopped Please stop first', self) if is_active?
  return false unless @container_api.destroy_container(self)  
  @container_id = '-1'
  expire_engine_info  
end

def unpause_container
  expire_engine_info  
  return true if read_state == 'running' 
  return log_error_mesg('Can\'t  unpause as no paused', self) unless is_paused?
  return false unless @container_api.unpause_container(self)
  expire_engine_info
end

def set_running_user
  @cont_userid = running_user if @cont_userid.nil? || @cont_userid == -1
end

def create_container   
  expire_engine_info  
  return log_error_mesg('Cannot create container as container exists ', self) if has_container?
      if @container_api.create_container(self)
        expire_engine_info
        @container_id = read_container_id
         p @container_id
        @cont_userid = running_user
        p @cont_userid
        return true
      end      
        @container_id = -1
        @cont_userid = ''
        return false      
  rescue => e
  log_exception(e)
end
#   /#<[a-z,A-Z]:0x[0-9][a-f]>/

def read_container_id
  info = docker_info
  return info[0]['Id'] unless info.is_a?(FalseClass) # Array) && docker_info[0].is_a?(Hash)    
    return -1
rescue StandardError => e
 log_exception(e)
end

def running_user
  info = docker_info
  return -1 if info.is_a?(FalseClass)
  return  info[0]['Config']['User'] unless info.is_a?(FalseClass)
rescue StandardError => e
  return log_exception(e)
end

def start_container
  expire_engine_info
  return true if read_state == 'running' 
  return log_error_mesg('Can\'t Start Container as ', self) unless read_state == 'stopped'
  return false unless @container_api.start_container(self)
  expire_engine_info   
end
def stop_container
  expire_engine_info  
  return true if read_state == 'stopped' 
  return log_error_mesg('Can\'t Stop Container as ', self) unless read_state == 'running'  
  return log_error_mesg('Api failure to stop container' + @container_api.last_error.to_s, self) unless @container_api.stop_container(self)
  expire_engine_info
end

def pause_container
  expire_engine_info
  return true if read_state == 'paused' 
  return log_error_mesg('Can\'t Pause Container as not running', self) unless is_running?
  return false unless @container_api.pause_container(self)  
  expire_engine_info
end

protected

def collect_docker_info
    return false unless has_api?  
    result = true
    result = @container_api.inspect_container(self) if @docker_info_cache.is_a?(FalseClass)
    return false unless result
    @docker_info_cache = @last_result
    Thread.new { sleep 6 ; expire_engine_info }
    return result
  end
end
