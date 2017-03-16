module PublicApiAvailableServices
  def load_avail_services_for_type(typename)
    @core_api.load_avail_services_for_type(typename)
  rescue StandardError => e
    handle_exception(e)
  end
end