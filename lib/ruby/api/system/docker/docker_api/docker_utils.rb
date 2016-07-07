module DockerUtils
  
  def self.docker_stream_as_result(r, h)
    
           return h if r.nil?
           
        while r.length >0
       if r[0].nil?
        return h if r.length == 1
        r = r[1..-1]
        next
        end
         if r[0].start_with?("\u0001\u0000\u0000\u0000")
          dst = :stdout
         elsif r[0].start_with?("\u0002\u0000\u0000\u0000")
           dst = :stderr
         else
           STDERR.puts('START ' + r[0..4].to_s)
          dst = :stdout
         end
     #"\u0001\u0000\u0000\u0000\u0000\u0000\u0000\u000b{\"certs\":[\n\u0001\u0000\u0000\u0000\u0000\u0000\u0000\n\"engines\"\n\u0001\u0000\u0000\u0000\u0000\u0000\u0000\u0003]}\n
         
       STDERR.puts("CONTENT " + r.to_s)
       p r
         r = r[4..-1]
         STDERR.puts(' R ' + r.to_s)
         size = r[0,3]
     STDERR.puts(' SIZE '  + size.to_s)
         length = size.unpack("N")
     STDERR.puts(' LENGTH '  + size.to_s + ' cn:' + length[0].class.name)
         #length = length[0]
         r = r[4..-1]
         l = r.index("\u0000\u0000\u0000")
         unless l.nil?
         length =  l - 1
         else
           length = r.length
         end
         STDERR.puts(' problem ' + r.to_s + ' has ' + r.length.to_s + ' bytes and length ' + length.to_s ) if r.length < length
         h[dst] += r[0..length-1]
         r = r[length..-1]
         end
     
        # FIXME need to get correct error status and set :stderr if app
        h[:result] = 0
        h
       end 
end