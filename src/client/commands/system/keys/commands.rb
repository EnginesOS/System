@route += '/' + ARGV[2]
case ARGV[2]
when 'user'
  require_relative 'user.rb'
else
  
  @route += '/' + ARGV[3] if ARGV.count > 3
@route += '/' + ARGV[4] if ARGV.count > 4

end