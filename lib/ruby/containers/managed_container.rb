require_relative 'container_statistics.rb'
require_relative 'ManagedContainerObjects.rb'

#require 'objspace' ??
require_relative 'container.rb'

class ManagedContainer < Container
#  require 'yajl'
#  require 'json'
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

  @conf_self_start = false
  @conf_zero_conf=false
  @restart_required = false
  @rebuild_required = false
  @large_temp = false

  attr_accessor  :volumes_from, :command, :restart_required, :rebuild_required, :environments, :volumes, :image_repo,:capabilities

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

  def set_state
    @setState
  end

  def to_s
    @container_name.to_s + '-set to:' +  @setState + ':' + status.to_s
  end
  
  def status
    @status = {} if @status.nil?
    @status[:state] = read_state
    @status[:set_state] = @setState
    @status[:progress_to] = task_at_hand
    @status[:error] = false
    @status[:oom] = @out_of_memory
    @status[:had_oom] = @had_out_memory
    @status[:restart_required] = restart_required?
    @status[:error] = true if @status[:state] != @status[:set_state] && @status[:progress_to].nil?
    @status
  end

  def post_load
    @container_mutex = Mutex.new
    i = @container_id
    super
    if @container_id != -1 && @container_id != i
      save_state
    end
  end

  def container_id
    return @container_id unless @container_id == -1
    return @container_id if setState == 'noncontainer'
    @container_id = read_container_id
    @container_id
  rescue
    -1
  end

  def repo
    @repository
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
  :no_ca_map,\
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
