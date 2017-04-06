def return_json(r, s = 202)
  return return_error(r) if r.is_a?(EnginesError)
  content_type 'application/json'
  status(s)
  return empty_json if r.nil?
  r.to_json
end

def return_json_array(r, s = 202)
  return return_error_array(r) if r.is_a?(EnginesError)
  content_type 'application/json'
  status(s)
  return empty_array if r.nil? || r == ''
  return empty_array if r.is_a?(FalseClass)
  r.to_json
end

def return_text(r, s = 202)
  return return_error(r) if r.is_a?(EnginesError)
  content_type 'text/plain'
  status(s)
  r.to_s
end

def return_true(s = 200)
  return_text('true', s)
end

def return_error(error, nil_result = nil)
  STDERR.puts(' RETURN ERROR!!!!!!!!' )
  content_type 'application/json'
  # FIXME: take this from the error if avail
  status(404)
  return nil_result if error.nil?
  error.to_json
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
