@route += '/containers/' + ARGV[0] + '/' + ARGV[1]
perform_get if ARGV.count == 2

case ARGV[2]
when 'mem_stat'
  @route += '/metrics/memory'
  perform_get
when 'net_stat'
  @route += '/metrics/network'
  perform_get

end

@route += '/' + ARGV[2]

case ARGV[2]
when 'service'
require_relative 'service.rb'
when 'services'
require_relative 'services.rb'

when 'actions'
@route += '/'
when 'action'
  require_relative 'action.rb'  

when 'consumers'
require_relative 'consumers.rb'
when 'consumer'
require_relative 'consumer.rb'
  
when 'configurations'
@route += '/' 
perform_get
when 'configuration'
require_relative 'configuration.rb'
  
when 'properties'
  require_relative 'properties.rb'
when 'template'
  params = {}
  params[:template_string] = ARGV[3]
  perform_post(params)
when 'destroy'

  perform_delete
when 'delete'

  perform_delete
end

perform_get

