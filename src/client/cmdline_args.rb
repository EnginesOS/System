def  process_args()
  r = true
  params = {}
  while ARGV[0].start_with?('-')
    r = process_flag(ARGV[0],params)
    return r if r.is_a?(String)
    ARGV.delete_at(0)
  end
  params
rescue StandardError => e
  return('Error:Problem with arg ' + ARGV[0].to_s)
end

def process_flag(flag,params)
  case flag
  when '-v'
    params[:verbose] = true
  when '-p'
    params[:password] = ARGV[1]
    ARGV.delete_at(0)
  when '-u'
    params[:username] = ARGV[1]
    ARGV.delete_at(0)
  when '-t'
    params[:access_token] = ARGV[1]
    ARGV.delete_at(0)
  when '--host'
    params[:host] = ARGV[1]
    ARGV.delete_at(0)
  when '--port'
    params[:port] = ARGV[1]
    ARGV.delete_at(0)
  when '--url'
    params[:base_url] = ARGV[1]
    ARGV.delete_at(0)
  when '--prefix'
    params[:prefix] = ARGV[1]
    ARGV.delete_at(0)
  else
    return('Error:Unknown option ' + flag.to_s)
  end
  return true
rescue StandardError => e
  return('Error:Problem with option ' + flag.to_s)
end

def get_help_info
  STDERR.puts('
    Options
   -v 
   -p password
   -u user
   -t token
   --port port
   --host host
   --url url
  --prefix prefix
  
  --url overides the following settings --host --port --prefix
  -v sets verbose
  Command ')

end