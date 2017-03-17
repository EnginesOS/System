def return_json(r, s=202)
  return return_error(r) if r.is_a?(EnginesError)
  content_type 'application/json'
  status(s)
  return empty_json if r.nil?
  STDERR.puts("JSON " + r.to_json)
  r.to_json
end

def return_json_array(r, s=202)
  return return_error_array(r) if r.is_a?(EnginesError)
  content_type 'application/json'
  status(s)
  STDERR.puts("json arry _" + r.to_s + '_')
  return empty_array if r.nil? || r == ''
  return empty_array if r.is_a?(FalseClass)
  r.to_json
end

def return_text(r, s=202)
  return return_error(r) if r.is_a?(EnginesError)
  content_type 'text/plain'
  STDERR.puts("text " + r.to_s)
  status(s)
  r.to_s
end

def return_true(s = 200)
  return return_error(s) if r.is_a?(EnginesError)
  return_text('true', s)
end

def return_error(error, nil_result = nil)
  content_type 'application/json'
  status(404) # FixMe take this from the error if avail
  STDERR.puts("JSON EROOR" + error.to_s)
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