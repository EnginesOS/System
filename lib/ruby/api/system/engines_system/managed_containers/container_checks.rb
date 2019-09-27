module ContainerChecks
  def containers_check_and_act
    services_status = get_services_status
    results = check_and_act(services_status, 'service')
    engines_status = get_engines_status
    results.merge!(check_and_act(engines_status, 'app'))
    results
  end
  protected

  def check_and_act(containers_status, ctype)

    raise EnginesException.new(warning_hash('System Starting up')) if SystemConfig.is_system_starting?
    raise EnginesException.new(warning_hash('System Shuting Down')) if SystemConfig.is_system_stopping?

    result = {}
    containers_status.keys.each do |container_name|
      if containers_status[container_name][:error] == true
        begin
          result[container_name] = act_on(container_name, ctype)
          # FixME use a fcntl or something to wait
          sleep 1
        rescue StandardError
        end
      else
        result[container_name] = 'ok'
      end
    end
    result
  end

  private
  
  def act_on(container_name, ctype)
    if ctype == 'app'
      container = loadManagedEngine(container_name)
    elsif ctype == 'service'
      container = loadManagedService(container_name)
    else
      container = loadSystemService(container_name)
    end
    container.correct_current_state
    'fixed'
  end
end