require_relative 'container_statistics.rb'
require_relative 'ManagedContainerObjects.rb'


#require 'objspace' ??

class ManagedContainer < Container
require_relative 'container.rb'
  
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
  require_relative 'managed_container/task_at_hand.rb'
  include TaskAtHand
  
  
  
  @conf_self_start = false
  @conf_zero_conf=false
  @restart_required = false
  @rebuild_required = false
  attr_accessor :task_at_hand, :restart_required, :rebuild_required
  

  # Note desired state is teh next step and not the final result desired state is stepped through
 
  def log_error_mesg(msg, e_object)
    task_failed(msg)
    super
  end

  def post_load
    @last_task =  @task_at_hand = nil
    super
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
  :setState,\
  :protocol,\
  :deployment_type,\
  :dependant_on,\
  :no_ca_map,\
  :hostname,\
  :domain_name,\
  :ctype,
  :conf_self_start


  def engine_name
    @container_name
  end

  def engine_environment
    return @environments
  end

  def to_s
    "#{@container_name.to_s}, #{@ctype}, #{@memory}, #{@hostname}, #{@conf_self_start}, #{@environments}, #{@image}, #{@volumes}, #{@web_port}, #{@mapped_ports}  \n"
  end



  def lock_values
    @conf_self_start.freeze
    @container_name.freeze
    @data_uid.freeze
    @data_gid.freeze
    @image.freeze
    @repository = '' if @repository.nil?
    @repository.freeze
  rescue StandardError => e
    log_exception(e)
  end

 
end
