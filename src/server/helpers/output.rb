def return_json(r, s = 202)
  if r.is_a?(EnginesError)
    return_error(r)
  else
    content_type 'application/json'
    status(s)
    if r.nil?
      empty_json
    else
      r.to_json
    end
  end
end

def return_json_array(r, s = 202)
  if r.is_a?(EnginesError)
    return_error_array(r)
  else
    content_type 'application/json'
    status(s)
    if r.nil? || r == '' || r.is_a?(FalseClass)
      empty_array
    else
      r.to_json
    end
  end
end

def return_text(r, s = 202)
  if r.is_a?(TrueClass) ||r.is_a?(FalseClass)
    return_boolean(r, s)
  elsif r.is_a?(EnginesError)
    return_error(r)
  else
    content_type 'text/plain'
    status(s)
    r.to_s
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
  content_type 'application/json'
  # FIXME: take this from the error if avail
  status(404)
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
