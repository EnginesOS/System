begin
  params_data = read_stdin_data
  command_usage unless params_data.is_a?(String)
  perform_post(json_parser.parse(params_data))
rescue StandardError => e
  puts('Not a json_parser String' + e.to_s + ' ' + e.backtrace.to_s)
end

