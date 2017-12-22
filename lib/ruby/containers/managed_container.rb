require_relative 'container_statistics.rb'
require_relative 'ManagedContainerObjects.rb'

require_relative 'container.rb'

class ManagedContainer < Container

  require_relative 'managed_container/task_at_hand.rb'
  include TaskAtHand
  require_relative 'managed_container/managed_container_controls.rb'
  include ManagedContainerControls
  require_relative 'managed_container/managed_container_dns.rb'
  include ManagedContainerDns
  require_relative 'managed_container/managed_container_image_controls.rb'
  include ManagedContainerImageControls
  require_relative 'managed_container/managed_container_status.rb'
  include ManagedContainerStatus
  require_relative 'managed_container/managed_container_volumes.rb'
  include  ManagedContainerVolumes
  require_relative 'managed_container/managed_container_web_sites.rb'
  include ManagedContainerWebSites
  require_relative 'managed_container/managed_container_api.rb'
  include ManagedContainerApi
  require_relative 'managed_container/persistent_services.rb'
  include PersistantServices
  require_relative 'managed_container/managed_container_actionators.rb'
  include ManagedContainerActionators
  require_relative 'managed_container/managed_container_environment.rb'
  include ManagedContainerEnvironment

  require_relative 'managed_container/managed_container_export_import_service.rb'
  include ManagedContainerExportImportService

  require_relative 'managed_container/managed_container_on_action.rb'
  include ManagedContainerOnAction

  require_relative 'managed_container/managed_container_certificates.rb'
  include ManagedContainerCertificates

  require_relative 'managed_container/managed_container_schedules.rb'
  include ManagedContainerSchedules
  
  require_relative 'managed_container/managed_container_services.rb'
  include ManagedContainerServices
  
  @conf_self_start = false
  @conf_zero_conf=false
  @restart_required = false
  @rebuild_required = false
  @large_temp = false
   
  attr_accessor  :restart_policy, :volumes_from, :command, :restart_required, :rebuild_required, :environments, :volumes, :image_repo, :capabilities, :conf_register_dns
  def initialize
    super
    @container_mutex = Mutex.new
    @status = {}
    init_task_at_hand
  end

  # Note desired state is teh next step and not the final result desired state is stepped through
  #  def log_error_mesg(msg, *objects)
  #    #task_failed(msg)
  #    super
  #  end

  def kerberos
    @kerberos = true if @kerberos.nil?
    @kerberos
  end    
  
  def no_cert_map
    false unless @no_cert_map == true
    true if @no_cert_map == true      
  end
  
  def set_state
    @setState
  end

  def to_s
    @container_name.to_s + '-set to:' +  @setState + ':' + status.to_s + ':' + @ctype
  end

  def status
    @status = {} if @status.nil?
    @status[:state] = read_state
      STDERR.puts(' STATE GOT ' + container_name.to_s + ':' + @status[:state].to_s)
    @status[:set_state] = @setState
    @status[:progress_to] = task_at_hand
    @status[:error] = false
    @status[:oom] = @out_of_memory
    @status[:why_stop] = @stop_reason
    @status[:had_oom] = @had_out_memory
    @status[:restart_required] = restart_required?
    @status[:error] = true if @status[:state] != @status[:set_state] && @status[:progress_to].nil?
    @status[:error] = false if @status[:state] == 'stopped' && is_stopped_ok?
    @status
  end

  def post_load
    @container_mutex = Mutex.new
    i = @container_id
    super
    status
    save_state if @container_id != -1 && @container_id != i
  end

  def container_id
    if @container_id == -1
      @container_id = read_container_id unless setState == 'noncontainer'
    end
    @container_id
  rescue
    -1
  end

  def repo
    @repository
  end

  def is_stopped_ok?
    @stopped_ok |= false
  end
  
  attr_reader :framework,\
  :runtime,\
  :repository,\
  :data_uid,\
  :data_gid,\
  :cont_userid,\
  :protocol,\
  :preffered_protocol,\
  :deployment_type,\
  :dependant_on,\
  :hostname,\
  :domain_name,\
  :ctype,
  :conf_self_start,
  :large_temp,
  :stop_timeout

  def engine_name
    @container_name
  end

  def engine_environment
    @environments
  end

  #  def to_s
  #    "#{@container_name.to_s}, #{@ctype}, #{@memory}, #{@hostname}, #{@conf_self_start}, #{@environments}, #{@image}, #{@volumes}, #{@web_port}, #{@mapped_ports}  \n"
  #  end
  def to_h
    s = self.dup
    envs = []
    unless environments.nil?
      s.environments.each do |env|
        envs.push(env.to_h)
      end
    end
    s.environments = envs
    unless volumes.nil?
      s.volumes.each_key do | key|
        s.volumes[key] = s.volumes[key].to_h
      end
    end
    s.instance_variables.each_with_object({}) do |var, hash|
      next if var.to_s.delete("@") == 'container_api'
      hash[var.to_s.delete("@")] = s.instance_variable_get(var)
    end
  end

  def lock_values
    @conf_self_start.freeze
    @container_name.freeze
    @data_uid.freeze
    @data_gid.freeze
    @image.freeze
    @repository = '' if @repository.nil?
    @repository.freeze

  end

  def error_type_hash(mesg, params = nil)
    {error_mesg: mesg,
      system: :managed_container,
      params: params }
  end
end
