module DockerUtils
  
  def self.process_request(data , result)
       to_send = data
       return_result = result
       STDERR.puts('PROCESS REQUEST init ' + to_send.to_s)
       lambda do |socket|
         STDERR.puts('PROCESS REQUEST Lambda')
         write_thread = Thread.start do 
           begin
       STDERR.puts('PROCESS REQUEST write thread ' + to_send.to_s)
            return socket.close_write if to_send.length == 0
            if to_send.length < Excon.defaults[:chunk_size]
              STDERR.puts('PROCESS REQUEST with single chunk ' + to_send.to_s)
              r = to_send
              to_send = ''
              socket.send(r,0)
              socket.close_write
            else
              socket.send(to_send.slice!(0,Excon.defaults[:chunk_size]),0)
            end
           rescue StandardError => e
               STDERR.puts(e.to_s + ':' + e.backtrace.to_s)
           end
         end
         read_thread = Thread.start do
           begin
             STDERR.puts('PROCESS REQUEST read thread')
           while chunk = socket.readpartial(1024)
             DockerUtils.docker_stream_as_result(chunk, return_result)
             STDERR.puts('PROCESS REQUEST read thread' + return_result.to_s)
           end          
          rescue EOFError 
             write_thread.kill
            
          rescue StandardError => e
             STDERR.puts(e.to_s + ':' + e.backtrace.to_s)
         end
           write_thread.kill
         end
         
         write_thread.join
         read_thread.join
      end
     rescue StandardError => e
       STDERR.puts('PROCESS Execp' + e.to_s + ' ' + e.backtrace.to_s )
       
     end


  def self.docker_stream_as_result(r, h)
    
           return h if r.nil?
           h[:stderr] = "" unless h.key?(:stderr)
           h[:stdout] = "" unless h.key?(:stdout)
               
        while r.length >0
       if r[0].nil?
        return h if r.length == 1
        r = r[1..-1]
        next
        end
         if r[0].start_with?("\u0001\u0000\u0000\u0000")
          r = r[7..-1]
          dst = :stdout
         elsif r[0].start_with?("\u0002\u0000\u0000\u0000")
           dst = :stderr
           r = r[7..-1]
         elsif r[0].start_with?("\u0000\u0000\u0000\u0000")
          dst = :stdout
          r = r[7..-1]
         else         
        # r = r[7..-1]
          dst = :stdout
         end
     #"\u0001\u0000\u0000\u0000\u0000\u0000\u0000\u000b{\"certs\":[\n\u0001\u0000\u0000\u0000\u0000\u0000\u0000\n\"engines\"\n\u0001\u0000\u0000\u0000\u0000\u0000\u0000\u0003]}\n
         
       STDERR.puts("CONTENT " + r.to_s)

         
         return h if r.nil?
         next_chunk = r.index("\u0000\u0000\u0000")
         unless next_chunk.nil?
          length =  next_chunk - 2
         else
           STDERR.puts(' wnd of string')
           length = r.length
         end
      #   STDERR.puts(' problem ' + r.to_s + ' has ' + r.length.to_s + ' bytes and length ' + length.to_s ) if r.length < length
         h[dst] += r[0..length-1]
         r = r[length..-1]
STDERR.puts(' still ave of string ' + r.to_s + ' with ' + r.length.to_s)
         end
     
        # FIXME need to get correct error status and set :stderr if app
        h[:result] = 0
        h
       end 
end