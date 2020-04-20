def return_json(r, s = 202)
  if r.is_a?(EnginesError)
    return_error(r)
  else
    content_type 'application/json; charset=UTF-8'
    headers['Access-Control-Allow-Origin'] ='*'
    status(s)
    if r.nil?
      empty_json
    else
      if r.is_a?(Hash)
        r[:stdout].force_encoding(Encoding::UTF_8) unless r[:stdout].nil?
        r[:stderr].force_encoding(Encoding::UTF_8) unless r[:stderr].nil?
      end
      r.to_json
    end
  end
end

def return_json_array(r, s = 202)
  if r.is_a?(EnginesError)
    return_error_array(r)
  else
    content_type 'application/json; charset=UTF-8'
    headers['Access-Control-Allow-Origin'] ='*'
    status(s)
    if r.nil? || r == '' || r.is_a?(FalseClass)
      empty_array
    else
      r.to_json
    end
  end
end

def return_text(r, s = 202)
  if r.nil?
    status(204)
  else
    if r.is_a?(TrueClass) || r.is_a?(FalseClass)
      return_boolean(r, s)
    elsif r.is_a?(Thread)
      return_boolean(true, s)
    elsif r.is_a?(EnginesError)
      return_error(r)
    else
      content_type 'text/plain'
      headers['Access-Control-Allow-Origin'] ='*'
      status(s)
      r.to_s
    end
  end
end

def return_stream(r, s = 202)
  if r.nil?
    status(204)
  else
    if r.is_a?(TrueClass) || r.is_a?(FalseClass)
      return_boolean(r, s)
    elsif r.is_a?(EnginesError)
      return_error(r)
    else
      content_type 'application/octet-stream'
      headers['Access-Control-Allow-Origin'] ='*'
      status(s)
      r.to_s
    end
  end
end

def return_true(s = 200)
  return_text('true', s)
end

def return_boolean(v, s = 200)
  v = true if v.nil? # meths return nil and when error they raise an exception
  return_text(v.to_s, s)
end

def return_error(error, nil_result = nil)
  # STDERR.puts(' RETURN ERROR!!!!!!!!' )
  content_type 'application/json; charset=UTF-8'
  headers['Access-Control-Allow-Origin'] ='*'
  # FIXME: take this from the error if avail
  status(403)
  if error.nil?
    nil_result
  else
    error.to_json
  end
end

def return_error_array(error)
  return_error(error, empty_array)
end

def empty_array
  @empty_array ||= [].to_json
end

def empty_json
  @empty_json ||= {}.to_json
end
