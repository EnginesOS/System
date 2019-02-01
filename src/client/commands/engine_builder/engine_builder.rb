
@route += '/' + ARGV[0] + '/' + ARGV[1] 
if ARGV[1] == 'resolve_blueprint'
params = {blueprint_url:  ARGV[2]} 
elsif ARGV[1] == 'follow'
  @route += '_stream'
  get_stream(@route)
else
  @route += '/' + ARGV[2] if ARGV.count >= 3
  perform_get(params)
end