if ARGV.count == 2
  @route += '/'
  perform_get
end


case ARGV[2]


when 'add'
@route += '/' + ARGV[2]
if ARGV.count < 6
  command_useage('missing arguments')
end
usage('missing cert file ') unless File.exist?(ARGV[4])
usage('missing key file ') unless  File.exist?(ARGV[5])

pass = nil
if ARGV.count == 7
  pass=ARGV[6]
end
params = {}
params[:domain_name] = ARGV[3]
params[:certificate] = File.read(ARGV[4])
params[:key] = File.read(ARGV[5])
params[:password] = pass unless pass.nil?

perform_post(params)
when 'remove'
@route += '/' + ARGV[2]
perform_delete
end


