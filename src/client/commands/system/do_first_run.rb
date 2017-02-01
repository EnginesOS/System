begin
  params_data = read_stdin_data
  command_usage unless params_data.is_a?(String)
  perform_post(JSON.parse(params_data), :create_additons => true )
rescue StandardError => e
  puts('Not a Json String' + e.to_s + ' ' + e.backtrace.to_s)
end

