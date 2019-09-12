class DockerDecoder
  @missing=0
  @dst=:stdout
  
  def initialize()
    @ini_params = {}
  end
  
  def initialize(params)
   @ini_params = params
 end
 
  def decode_from_docker_chunk(p)
    frag_p = @ini_params.dup
    frag_p.merge!(p)   
    frag_p[:result] = {
      stderr: '',
      stdout: ''
    } unless frag_p.key?(:result)
    docker_stream_as_result(frag_p)
    frag_p[:result]
  end

  def extract_chunk(p)
    l = p[:chunk][0..7].unpack('C*')
    p[:cl] = l[7] + l[6] * 256 + l[5] * 4096 + l[4] * 65536 + l[3] * 1048576
    p[:chunk] = p[:chunk][8..-1]
    STDERR.puts('chunk ' + p[:chunk].to_s + ' dest ' + @dst.to_s + ' len ' + l.to_s)      
  end

  def docker_stream_as_result(frag_p) #chunk, result, binary = true, stream = nil)
    STDERR.puts('Stream as r ' + frag_p.to_s)
    unmatched = false
    frag_p[:binary] = true unless frag_p.key?(:binary)
      
    unless frag_p[:result].nil?
      frag_p[:result][:stderr] = '' unless frag_p[:result].key?(:stderr)
      frag_p[:result][:stdout] = '' unless frag_p[:result].key?(:stdout)

      unless frag_p[:chunk].nil?
        while frag_p[:chunk].length > 0
          if frag_p[:chunk][0].nil?
            return frag_p[:result] if frag_p[:chunk].length == 1
            STDERR.puts('Skipping nil ')
            frag_p[:chunk] = frag_p[:chunk][1..-1]
            next
          end
          if @missing != 0
            frag_p[:cl] = @missing
            @missing = 0
          elsif  frag_p[:chunk].start_with?("\u0001\u0000\u0000\u0000")
            @dst = :stdout
            extract_chunk(frag_p)
          elsif  frag_p[:chunk].start_with?("\u0002\u0000\u0000\u0000")
            @dst = :stderr
            extract_chunk(frag_p)
          elsif  frag_p[:chunk].start_with?("\u0000\u0000\u0000\u0000")
            @dst = :stdout
            STDERR.puts('Matched \0\0\0')
          else
            STDERR.puts('UNMATCHED ' +  frag_p[:chunk].length.to_s)#chunk.to_s)#.length.to_s)
            @dst = :stdout
            unmatched = true
          end
          return frag_p[:result] if frag_p[:chunk].nil?

          unless unmatched == true
            length = frag_p[:cl]
          else
            length = frag_p[:chunk].length
          end

          if length > frag_p[:chunk].length
            @missing = length - frag_p[:chunk].length
            length = frag_p[:chunk].length
          end
          if @dst == :stderr
            frag_p[:result][@dst] += frag_p[:chunk][0..length-1]
          else
            if frag_p.key?(:stream)
              frag_p[:stream].write(frag_p[:chunk][0..length-1])
            else
              frag_p[:result][@dst] += frag_p[:chunk][0..length-1]
            end
          end
          frag_p[:chunk] = frag_p[:chunk][length..-1]
          #     if  frag_p[:chunk].length > 0
          #       STDERR.puts('Continuation')
          #     end
        end
      end
      # result actually set elsewhere after exec complete
      frag_p[:result][:result] = 0
      unless frag_p[:binary]
        frag_p[:result][:stdout].force_encoding(Encoding::UTF_8) unless frag_p[:result][:stdout].nil? || ! stream.nil?
        frag_p[:result][:stderr].force_encoding(Encoding::UTF_8) unless frag_p[:result][:stderr].nil?
      end
    end
    frag_p[:result]
  end
end