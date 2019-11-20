module Container
  class ManagedEngine < ManagedContainer
    class << self
      def store
        @@store ||= Store.new
      end
    end

    require '/opt/engines/lib/ruby/containers/managed_container.rb'
    require_relative 'managed_engine/managed_engine_on_action.rb'
    include ManagedEngineOnAction

    def_delegators :@memento,
    :plugins_path,
    :extract_plugins,
    :web_root

    def ctype
        @ctype ||= 'app'
      end

    def apply_build_params(build_params, runtime_params)
      memory = build_params[:memory]
      container_name = build_params[:engine_name]
      image = build_params[:image]
      web_port = build_params[:web_port]
      mapped_ports = build_params[:mapped_ports]
      set_state = 'running'

      last_error = 'None'
      last_result = ''

     framework = runtime_params.framework
      runtime = runtime_params.runtime
      repository  = build_params[:repository_url]
      data_uid = build_params[:data_uid]
      data_gid = build_params[:data_gid]
      cont_user_id = build_params[:cont_user_id]
      protocol = build_params[:http_protocol]
      # what about preferred protocol? Missing
      deployment_type = runtime_params.deployment_type
      # what about dependent on? Only relevant for services
      hostname = build_params[:host_name]
      domain_name = build_params[:domain_name]
      conf_self_start = true
      # what about large_temp? currently only servics

      # what about restart_policy ?   flag file is the store
      # what about restart_required?   ""
      # what about rebuild_required?   ""
      volumes = build_params[:volumes]
      # what about volumes_from?  Managedutiliy
      # what about command?  #fixed in apps/services/systemservices used Managedutiliy
      environments = runtime_params.environments
      # what about image_repo? inferred in apps from name but ..
      capabilities = runtime_params.capabilities
      conf_register_dns = true

      conf_zero_conf = true
      host_network = false
      web_root = runtime_params.web_root
      @volume_service_builder = build_params[:service_builder]

      expire_engine_info
      save_state # no running.yaml throws a no such container so save so others can use
    end

    def restart_complete_install?
      restart_required?
    end

    def volume_service_builder=(is_built)
      #   STDERR.puts(' SET @service_builder.run_volume_builder ' +  builder.to_s )
      @volume_service_builder = is_built
    end

    def load_blueprint
      container_dock.load_blueprint(container_name)
    end

    def plugins_path
      '/plugins/'
    end

    def extract_plugins
      false
    end

    def info_fs
      @info_fs ||= super.merge({ frame_work: @framework })
    end

    def add_shared_volume(service_hash)
      volume_name = "#{service_hash[:owner]}_#{service_hash[:service_handle]}"
      volumes[volume_name] = {
        volume_name: volume_name,
        localpath: service_hash[:variables][:volume_src],
        remotepath: service_hash[:variables][:engine_path],
        permissions: service_hash[:variables][:permissions],
        user: service_hash[:variables][:user],
        group: service_hash[:variables][:group]
      }
      save_state
    end

    def engine_attached_services
      container_dock.engine_attached_services(self)
    end

    def error_type_hash(mesg, params = nil)
      {error_mesg: mesg,
        system: :managed_engine,
        params: params }
    end
  end
end
