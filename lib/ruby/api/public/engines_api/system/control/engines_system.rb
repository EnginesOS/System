module PublicApiSystemControlEnginesSystem
  def update_engines_system_software
  @core_api.update_engines_system_software
  end
  def restart_engines_system
  @core_api.restart_engines_system
  end
  def recreate_mgmt
  @core_api.recreate_mgmt
  end
  def dump_heap_stats
    @core_api.dump_heap_stats
  end
  
  def is_token_valid?(token, ip =nil)
    @core_api.is_token_valid?(token, ip =nil)
#  #  request.env["REMOTE_ADDR"]
#  if ip == nil
#    rows = @core_api.sql_lite_database.execute( 'select guid from systemaccess where authtoken=' + "'" + token.to_s + "'" )
#  else
#    rows = @core_api.sql_lite_database.execute( 'select guid from systemaccess where authtoken=' + "'" + token.to_s + "' and ip_addr ='" + request.env["REMOTE_ADDR"].to_s + "'" )
#  end
#  return false unless rows.count > 0
#  return rows[0]
#rescue StandardError => e
#  STDERR.puts(' toekn verify error  ' + e.to_s)
#  STDERR.puts(' toekn verify error exception name  ' + e.class.name)
#  return false
#  
end

 
end