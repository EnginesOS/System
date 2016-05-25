@route += '/' + ARGV[2] 
case ARGV[2]
when 'service_definitions'
  @route += '/' + ARGV[3] +  '/' + ARGV[4]
end

perform_get