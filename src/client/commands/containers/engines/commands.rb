@route += '/containers/' + ARGV[0] +'/'
if ARGV.count == 1
  perform_get
end

@route +=  ARGV[1]
case ARGV[1]
when 'state'
  perform_get
when 'build'
  require_relative 'build.rb'  
when 'container_name'
  perform_get

end
perform_get