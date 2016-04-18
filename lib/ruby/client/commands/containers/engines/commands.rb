@route += '/containers/' + ARGV[0] +'/'
if ARGV.count == 1
  perform_get
end

@route +=  ARGV[1]
case ARGV[1]
when 'state'
  perform_get
when 'container_name'
  perform_get

end