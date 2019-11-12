require_relative 'container_statistics.rb'
require_relative 'ManagedContainerObjects.rb'

require_relative 'container.rb'

module Container
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
    require_relative 'managed_container/managed_container_dock.rb'
    include ManagedContainerDock
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

    #    @conf_self_start = false
    #    @conf_zero_conf=false
    #    @restart_required = false
    #    @rebuild_required = false
    #    @large_temp = false

    def_delegators :memento,
      :restart_policy,
      :volumes_from,
      :command,
      :restart_required,
      :rebuild_required,
      :environments,
      :volumes,
      :image_repo,
      :capabilities,
      :conf_register_dns
      :framework,
      :runtime,
      :repository,
      :data_uid,
      :data_gid,
      :cont_user_id,
      :protocol,
      :preffered_protocol,
      :deployment_type,
      :dependant_on,
      :hostname,
      :domain_name,
      :ctype,
      :conf_self_start,
      :large_temp

    def initialize
      super
      @status = {}
      init_task_at_hand
    end

    def store
      self.class.store
    end

    def info_fs
      @info_fs ||= store_address.merge({uid: cont_user_id})
    end

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
      "#{@container_name}-set to:#{@setState}:#{status}:#{@ctype}"
    end

    def store_address
      @store_address ||= { c_name: @container_name.to_s, c_type: @ctype.to_s }
    end

    def status
      @status = {} if @status.nil?
      @status[:state] = read_state
      # STDERR.puts(' STATE GOT ' + container_name.to_s + ':' + @status[:state].to_s)
      @status[:set_state] = @setState
      @status[:progress_to] = task_at_hand
      @status[:error] = false
      @status[:oom] = @out_of_memory
      @status[:why_stop] = @stop_reason
      @status[:had_oom] = @had_out_memory
      @status[:restart_required] = restart_required?
      @status[:error] = true if @status[:state] != @status[:set_state] && @status[:progress_to].nil?
      @status[:error] = false if @status[:state] == 'stopped' && is_stopped_ok?
      # STDERR.puts(' STATUS ' + @status.to_s)
      @status
    end

    def post_load
      i = @id
      container_mutex.synchronize {
        super
        status
      }
    end

    def repo
      @repository
    end

    def is_stopped_ok?
      @stopped_ok |= false
    end

    def engine_name
      @container_name
    end

    def engine_environment
      @environments
    end

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
        next if var.to_s.delete("@") == 'container_dock'
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

  def container_save
    @container_save ||= Mutex.new
  end

  def container_mutex
    @container_mutex ||= Mutex.new
  end
end
