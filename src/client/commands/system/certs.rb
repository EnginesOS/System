if ARGV.count == 2
  @route += '/'
  perform_get
end

case ARGV[2]
when 'default'
  @route += '/' + ARGV[2] + '/' + ARGV[3]
  @route +=  '/' + ARGV[4] if ARGV.count == 5
  perform_post(nil)
when 'system_ca'
  perform_get
when 'view'
  perform_get
when 'generate'
  @route += '/generate'
  params_data = read_stdin_data
  perform_post(json_parser.parse(params_data))
when 'default'
  @route += '/default'
  if ARGV.count < 6
    command_usage('missing arguments')
  else
    command_usage('missing cert file ') unless File.exist?(ARGV[4])
    command_usage('missing key file ') unless  File.exist?(ARGV[5])

    pass = nil
    if ARGV.count == 7
      pass=ARGV[6]
    end
    params = {
      domain_name: ARGV[3],
      certificate: File.read(ARGV[4]),
      key: File.read(ARGV[5])
    }
    params[:password] = pass unless pass.nil?
    perform_post(params)
  end
when 'add'
  @route += '/'
  if ARGV.count < 6
    command_usage('missing arguments')
  else
    command_usage('missing cert file ') unless File.exist?(ARGV[4])
    command_usage('missing key file ') unless File.exist?(ARGV[5])

    pass = nil
    pass = ARGV[6]if ARGV.count == 7

    params = {
      domain_name: ARGV[3],
      certificate: File.read(ARGV[4]),
      key: File.read(ARGV[5])
    }
    params[:password] = pass unless pass.nil?
    perform_post(params)
  end
when 'remove'
  @route += '/' + ARGV[3]
  perform_delete
end
@route += '/' + ARGV[2]
perform_get