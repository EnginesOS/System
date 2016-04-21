@route += '/'
case ARGV
when 3
  perform_get 
when 4
  @route += '/'+ ARGV[3]
  p :OPOO
 p @route
end

perform_get
  
