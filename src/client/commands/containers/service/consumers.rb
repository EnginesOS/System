@route += '/'
case ARGV.count
when 3
  perform_get 
when 4
  @route +=  ARGV[3]

end

perform_get
  
