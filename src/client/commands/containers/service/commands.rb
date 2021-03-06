@route += '/containers/' + ARGV[0] + '/' + ARGV[1]
perform_get if ARGV.count == 2

case ARGV[2]
when 'imports'
 @route += '/imports'
STDERR.puts("Route #{@route}")
content_type='application/octet-stream'
 stream_io(@route, STDIN)

when 'import'
  @route += '/import'
if ARGV.count == 4
  STDERR.puts('read file')
  file = File.new(ARGV[3])
  stream_file(@route, file)
else
STDERR.puts('read stream')
estream_io(@route, STDIN)
#stream_io(@route, STDIN)
end  
  
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
when 'action','stream_action'
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

when 'wait_for'
  @route += '/' + ARGV[3] if ARGV.count > 3
  if ARGV.count > 4
    @route += '/' + ARGV[4]
    perform_get(ARGV[4].to_i + 1)
  else
    perform_get
  end

else
  @route += '/' + ARGV[3] if ARGV.count > 3
  @route += '/' + ARGV[4] if ARGV.count > 4
  perform_get
end

