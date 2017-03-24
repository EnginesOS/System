module ManagedServiceReaders
  
  def retrieve_reader(reader_name)
    raise EnginesException.new(error_hash('service not running ', params)) if is_running? == false
    raise EnginesException.new(error_hash('service missing cont_userid ', params)) if check_cont_uid == false
    @container_api.retrieve_reader(self, reader_name)
  end
  
  def get_readers
    @container_api.get_readers(self)
  end
end