module ManagedEngineOnAction
  def on_start(event_hash)
    if @volume_service_builder == true
      STDERR.puts('RuN VOLBUILER ' + cont_user_id.to_s + ':' + container_name)
      container_dock.run_volume_builder(self, cont_user_id, 'all')
      @volume_service_builder = false
    end
    super
  end
end