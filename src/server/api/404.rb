
get '/v0/*' do
  STDERR.puts :No_Such_GET
  STDERR.puts request.fullpath.to_s  
  STDERR.puts 'params'
  STDERR.puts params
  status(404)
end
  put '/v0/*' do
     STDERR.puts :No_Such_put
     STDERR.puts request.fullpath.to_s  
     STDERR.puts 'params'
     STDERR.puts params
     status(404)
   end

  index '/v0/*' do
     STDERR.puts :No_Such_Index
     STDERR.puts request.fullpath.to_s  
     STDERR.puts 'params'
     STDERR.puts params
     status(404)
   end