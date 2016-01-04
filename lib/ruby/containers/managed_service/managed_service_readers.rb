module ManagedServiceReaders
  
  def retrieve_reader(reader_name)
    return log_error_mesg('service not running ',params) if is_running? == false
    return log_error_mesg('service missing cont_userid ',params) if check_cont_uid == false
    @container_api.retrieve_reader(self, reader_name)
  end
end