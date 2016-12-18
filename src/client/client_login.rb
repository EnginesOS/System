def login
  r = rest_get('/v0/system/login/admin/EnginesDemo')
  puts r
  ENV['access_token'] = r.body.gsub!(/\"/,'')
  t = File.new(Dir.home + '/.engines_token','w+')
  t.write(ENV['access_token'])
  t.close
end

def load_token
  return false unless File.exist?(Dir.home + '/.engines_token')
  ENV['access_token'] = File.read(Dir.home + '/.engines_token')
  ENV['access_token'] = ENV['access_token'].strip
  ENV['access_token']
end