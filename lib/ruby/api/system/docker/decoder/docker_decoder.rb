class DockerDecoder
  def initialize()
    @ini_params = {binary: false}
    @missing=0
    @dst=:stdout
  end

def initialize(params = {})
    @ini_params = params
    @missing=0
    @dst=:stdout
    @ini_params[:binary] = false unless params.key?(:binary)
  end

  def decode_from_docker_chunk(p)
    frag_p = @ini_params.dup
    frag_p.merge!(p)
    frag_p[:result] = {
      stderr: '',
      stdout: '',
      result: 0
    } unless frag_p.key?(:result)
    docker_stream_as_result(frag_p)
    frag_p[:result]
  end

  def extract_chunk(p)
    l = p[:chunk][0..7].unpack('C*')
    p[:cl] = l[7] + l[6] * 256 + l[5] * 4096 + l[4] * 65536 + l[3] * 1048576
    p[:chunk] = p[:chunk][8..-1]
    p[:cl] = p[:chunk].length if p[:cl]  == 0
  end

  def skip_nil(frag_p)
    if frag_p[:chunk][0].nil?
      return frag_p[:result] if frag_p[:chunk].length == 1
      frag_p[:chunk] = frag_p[:chunk][1..-1]
      true
    end
    false
  end

  def extract_data_and_source(frag_p)
    r = true
    if @missing != 0
      frag_p[:cl] = @missing
      @missing = 0
    elsif frag_p[:chunk].start_with?("\u0001\u0000\u0000\u0000")
      @dst = :stdout
  #    STDERR.puts('MATCHED stdout ' +  frag_p[:chunk].length.to_s)
      extract_chunk(frag_p)
    elsif frag_p[:chunk].start_with?("\u0002\u0000\u0000\u0000")
      @dst = :stderr
      extract_chunk(frag_p)
    elsif frag_p[:chunk].start_with?("\u0000\u0000\u0000\u0000")
      @dst = :stdout
      STDERR.puts('Matched \0\0\0')
    else
      STDERR.puts('UNMATCHED ' +  frag_p[:chunk].length.to_s)#chunk.to_s)#.length.to_s)
      @dst = :stdout
      r = false
    end
    r
  end

  def create_blank_result(frag_p)
    frag_p[:result] = {} unless frag_p.key?(:result) 
    frag_p[:result][:stderr] = '' unless frag_p[:result][:stderr]
    frag_p[:result][:stdout] = '' unless frag_p[:result][:stdout]
  end

  def force_encoding(result)
    result[:stdout].force_encoding(Encoding::UTF_8) unless result[:stdout].nil? || ! stream.nil?
    result[:stderr].force_encoding(Encoding::UTF_8) unless result[:stderr].nil?
  end

  def docker_stream_as_result(frag_p) #chunk, result, binary = true, stream = nil)
    create_blank_result(frag_p) 
    unless frag_p[:chunk].nil?
      while frag_p[:chunk].length > 0
         next if skip_nil(frag_p)
        if extract_data_and_source(frag_p)
          pkt_length = frag_p[:cl]
        else #no match
          pkt_length = frag_p[:chunk].length
        end

    #    STDERR.puts('FPGRA ' + frag_p[:chunk].length.to_s + ' chunk ' + frag_p[:cl].to_s + ' pkt ' + pkt_length.to_s )
        if pkt_length > frag_p[:chunk].length
          @missing = pkt_length - frag_p[:chunk].length
          pkt_length = frag_p[:chunk].length
        end

        if @dst == :stderr #/stderr only goes in the result never the stream
          frag_p[:result][:stderr] += frag_p[:chunk][0..pkt_length-1]
        else
          if frag_p.key?(:stream)
            frag_p[:stream].write(frag_p[:chunk][0..pkt_length-1])
          else
            frag_p[:result][@dst] += frag_p[:chunk][0..pkt_length-1]
        #    STDERR.puts('frag_p[:result] ' + frag_p[:chunk][0..pkt_length-1].to_s)
          end
        end
        frag_p[:chunk] = frag_p[:chunk][pkt_length..-1]
     #   STDERR.puts('Continuation')  if frag_p[:chunk].length > 0
      end
    end
    frag_p[:result]
  rescue =>e
    STDERR.puts('Exception E ' + e.to_s + "\n" )
    raise e
  end
end